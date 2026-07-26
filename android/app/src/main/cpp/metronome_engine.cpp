#include <jni.h>

#include <android/log.h>
#include <oboe/Oboe.h>

#include <algorithm>
#include <array>
#include <atomic>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <memory>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

namespace {

#ifndef NDEBUG
#define METRONOME_LOG(...) \
  __android_log_print(ANDROID_LOG_DEBUG, "TunathicMetronome", __VA_ARGS__)
#else
#define METRONOME_LOG(...) ((void)0)
#endif

constexpr int32_t kMinimumBpm = 20;
constexpr int32_t kMaximumBpm = 300;
constexpr size_t kEventCapacity = 128;
constexpr int32_t kTailFadeMilliseconds = 3;
std::atomic<int64_t> gNextEngineInstanceId{0};

enum class EngineLifecycleState : int32_t {
  Uninitialized,
  Initialized,
  Starting,
  Running,
  Stopping,
  Stopped,
  Recovering,
  Failed,
  Disposed,
};

const char* lifecycleStateName(EngineLifecycleState state) {
  switch (state) {
    case EngineLifecycleState::Uninitialized:
      return "uninitialized";
    case EngineLifecycleState::Initialized:
      return "initialized";
    case EngineLifecycleState::Starting:
      return "starting";
    case EngineLifecycleState::Running:
      return "running";
    case EngineLifecycleState::Stopping:
      return "stopping";
    case EngineLifecycleState::Stopped:
      return "stopped";
    case EngineLifecycleState::Recovering:
      return "recovering";
    case EngineLifecycleState::Failed:
      return "failed";
    case EngineLifecycleState::Disposed:
      return "disposed";
  }
  return "unknown";
}

struct WavData {
  int32_t sampleRate = 0;
  std::vector<int16_t> samples;
};

struct BeatEvent {
  int64_t runId = 0;
  int64_t streamGeneration = 0;
  uint64_t configRevision = 0;
  int32_t sequence = 0;
  int32_t beatNumber = 0;
  bool accented = false;
  int64_t audioFramePosition = 0;
  int64_t callbackTimeNanos = 0;
};

uint16_t readU16(const uint8_t* data) {
  return static_cast<uint16_t>(data[0]) |
         static_cast<uint16_t>(data[1] << 8);
}

uint32_t readU32(const uint8_t* data) {
  return static_cast<uint32_t>(data[0]) |
         (static_cast<uint32_t>(data[1]) << 8) |
         (static_cast<uint32_t>(data[2]) << 16) |
         (static_cast<uint32_t>(data[3]) << 24);
}

bool chunkEquals(const uint8_t* data, const char* value) {
  return std::memcmp(data, value, 4) == 0;
}

WavData parsePcm16MonoWav(const std::vector<uint8_t>& bytes) {
  if (bytes.size() < 44 || !chunkEquals(bytes.data(), "RIFF") ||
      !chunkEquals(bytes.data() + 8, "WAVE")) {
    throw std::invalid_argument("Click asset is not a RIFF/WAVE file");
  }

  uint16_t format = 0;
  uint16_t channels = 0;
  uint16_t bitsPerSample = 0;
  uint32_t sampleRate = 0;
  const uint8_t* pcm = nullptr;
  size_t pcmSize = 0;

  size_t offset = 12;
  while (offset + 8 <= bytes.size()) {
    const uint8_t* header = bytes.data() + offset;
    const uint32_t chunkSize = readU32(header + 4);
    const size_t dataOffset = offset + 8;
    if (dataOffset + chunkSize > bytes.size()) {
      throw std::invalid_argument("Click WAV contains a truncated chunk");
    }
    if (chunkEquals(header, "fmt ") && chunkSize >= 16) {
      format = readU16(bytes.data() + dataOffset);
      channels = readU16(bytes.data() + dataOffset + 2);
      sampleRate = readU32(bytes.data() + dataOffset + 4);
      bitsPerSample = readU16(bytes.data() + dataOffset + 14);
    } else if (chunkEquals(header, "data")) {
      pcm = bytes.data() + dataOffset;
      pcmSize = chunkSize;
    }
    offset = dataOffset + chunkSize + (chunkSize % 2);
  }

  if (format != 1 || channels != 1 || bitsPerSample != 16 ||
      sampleRate == 0 || pcm == nullptr || pcmSize == 0 ||
      pcmSize % sizeof(int16_t) != 0) {
    throw std::invalid_argument(
        "Click WAV must be mono little-endian PCM16 with audio data");
  }

  WavData result;
  result.sampleRate = static_cast<int32_t>(sampleRate);
  result.samples.resize(pcmSize / sizeof(int16_t));
  for (size_t index = 0; index < result.samples.size(); ++index) {
    result.samples[index] =
        static_cast<int16_t>(readU16(pcm + index * sizeof(int16_t)));
  }
  return result;
}

std::vector<int16_t> resample(
    const WavData& source,
    int32_t targetSampleRate) {
  if (source.sampleRate == targetSampleRate) {
    return source.samples;
  }
  const double scale =
      static_cast<double>(targetSampleRate) / source.sampleRate;
  const size_t outputLength = std::max<size_t>(
      1, static_cast<size_t>(std::llround(source.samples.size() * scale)));
  std::vector<int16_t> output(outputLength);
  for (size_t index = 0; index < outputLength; ++index) {
    const double sourcePosition = index / scale;
    const size_t lower = std::min(
        static_cast<size_t>(sourcePosition), source.samples.size() - 1);
    const size_t upper = std::min(lower + 1, source.samples.size() - 1);
    const double fraction = sourcePosition - lower;
    const double value =
        source.samples[lower] * (1.0 - fraction) +
        source.samples[upper] * fraction;
    output[index] = static_cast<int16_t>(std::clamp(
        std::llround(value),
        static_cast<long long>(INT16_MIN),
        static_cast<long long>(INT16_MAX)));
  }
  return output;
}

void applyTailFade(std::vector<int16_t>& samples, int32_t sampleRate) {
  const size_t fadeFrames = std::min(
      samples.size(),
      static_cast<size_t>(
          sampleRate * kTailFadeMilliseconds / 1000));
  if (fadeFrames == 0) {
    return;
  }
  const size_t start = samples.size() - fadeFrames;
  for (size_t index = 0; index < fadeFrames; ++index) {
    const double gain =
        static_cast<double>(fadeFrames - index - 1) / fadeFrames;
    samples[start + index] =
        static_cast<int16_t>(std::llround(samples[start + index] * gain));
  }
  samples.back() = 0;
}

int64_t monotonicNanos() {
  return std::chrono::duration_cast<std::chrono::nanoseconds>(
             std::chrono::steady_clock::now().time_since_epoch())
      .count();
}

class NativeMetronome final : public oboe::AudioStreamDataCallback,
                              public oboe::AudioStreamErrorCallback {
 public:
  NativeMetronome(JavaVM* javaVm, JNIEnv* env, jobject owner)
      : javaVm_(javaVm),
        owner_(env->NewGlobalRef(owner)),
        engineInstanceId_(
            gNextEngineInstanceId.fetch_add(1, std::memory_order_relaxed) +
            1) {
    const jclass ownerClass = env->GetObjectClass(owner);
    beatMethod_ = env->GetMethodID(
        ownerClass, "onNativeBeat", "(JJIIZJJ)V");
    errorMethod_ = env->GetMethodID(
        ownerClass,
        "onNativeError",
        "(JJLjava/lang/String;Ljava/lang/String;)V");
    env->DeleteLocalRef(ownerClass);
    if (owner_ == nullptr || beatMethod_ == nullptr || errorMethod_ == nullptr) {
      throw std::runtime_error("Could not bind native metronome callbacks");
    }
    METRONOME_LOG(
        "event=create engine=%lld state=uninitialized",
        static_cast<long long>(engineInstanceId_));
    dispatcher_ = std::thread([this] { dispatchLoop(); });
  }

  ~NativeMetronome() override {
    dispose();
    lifecycleState_.store(
        EngineLifecycleState::Disposed, std::memory_order_release);
    METRONOME_LOG(
        "event=destroy engine=%lld",
        static_cast<long long>(engineInstanceId_));
    shutdownDispatcher_.store(true, std::memory_order_release);
    if (dispatcher_.joinable()) {
      dispatcher_.join();
    }
    JNIEnv* env = nullptr;
    bool attached = false;
    if (javaVm_->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) !=
        JNI_OK) {
      if (javaVm_->AttachCurrentThread(&env, nullptr) == JNI_OK) {
        attached = true;
      }
    }
    if (env != nullptr && owner_ != nullptr) {
      env->DeleteGlobalRef(owner_);
      owner_ = nullptr;
    }
    if (attached) {
      javaVm_->DetachCurrentThread();
    }
  }

  void initialize(
      const std::vector<uint8_t>& regularWavBytes,
      const std::vector<uint8_t>& accentWavBytes,
      int32_t bpm,
      int32_t beatsPerMeasure,
      int32_t beatUnit,
      float volume,
      bool accentEnabled) {
    validateConfig(bpm, beatsPerMeasure, beatUnit, volume);
    METRONOME_LOG(
        "event=initialize engine=%lld bpm=%d signature=%d/%d",
        static_cast<long long>(engineInstanceId_),
        bpm,
        beatsPerMeasure,
        beatUnit);
    dispose();

    const WavData regularSource = parsePcm16MonoWav(regularWavBytes);
    const WavData accentSource = parsePcm16MonoWav(accentWavBytes);

    oboe::AudioStreamBuilder builder;
    builder.setDirection(oboe::Direction::Output);
    builder.setPerformanceMode(oboe::PerformanceMode::LowLatency);
    builder.setSharingMode(oboe::SharingMode::Shared);
    builder.setUsage(oboe::Usage::Media);
    builder.setContentType(oboe::ContentType::Sonification);
    builder.setFormat(oboe::AudioFormat::I16);
    builder.setChannelCount(oboe::ChannelCount::Mono);
    builder.setDataCallback(this);
    builder.setErrorCallback(this);
    builder.setSampleRateConversionQuality(
        oboe::SampleRateConversionQuality::Medium);

    const oboe::Result openResult = builder.openStream(stream_);
    if (openResult != oboe::Result::OK || stream_ == nullptr) {
      throw std::runtime_error(
          std::string("Could not open low-latency output stream: ") +
          oboe::convertToText(openResult));
    }

    sampleRate_ = stream_->getSampleRate();
    channelCount_ = stream_->getChannelCount();
    framesPerBurst_ = stream_->getFramesPerBurst();
    if (sampleRate_ <= 0 || channelCount_ <= 0 || framesPerBurst_ <= 0) {
      dispose();
      throw std::runtime_error(
          "Native audio stream returned invalid output properties");
    }

    const auto bufferResult =
        stream_->setBufferSizeInFrames(framesPerBurst_ * 2);
    bufferSizeFrames_ = bufferResult
        ? bufferResult.value()
        : stream_->getBufferCapacityInFrames();
    const int64_t streamGeneration =
        streamGeneration_.fetch_add(1, std::memory_order_acq_rel) + 1;
    static_cast<void>(streamGeneration);
    activeStream_.store(stream_.get(), std::memory_order_release);
    regularClick_ = resample(regularSource, sampleRate_);
    accentClick_ = resample(accentSource, sampleRate_);
    applyTailFade(regularClick_, sampleRate_);
    applyTailFade(accentClick_, sampleRate_);

    bpm_.store(bpm, std::memory_order_relaxed);
    beatsPerMeasure_.store(beatsPerMeasure, std::memory_order_relaxed);
    beatUnit_.store(beatUnit, std::memory_order_relaxed);
    volume_.store(volume, std::memory_order_relaxed);
    accentEnabled_.store(accentEnabled, std::memory_order_relaxed);
    configRevision_.fetch_add(1, std::memory_order_release);
    signatureRevision_.fetch_add(1, std::memory_order_release);
    lifecycleState_.store(
        EngineLifecycleState::Initialized, std::memory_order_release);
    METRONOME_LOG(
        "event=stream_open engine=%lld streamGeneration=%lld state=%s "
        "oboeState=%s api=%s sampleRate=%d channels=%d framesPerBurst=%d "
        "bufferCapacity=%d bufferSize=%d performanceMode=%s sharingMode=%s "
        "deviceId=%d",
        static_cast<long long>(engineInstanceId_),
        static_cast<long long>(streamGeneration),
        lifecycleStateName(getLifecycleState()),
        oboe::convertToText(stream_->getState()),
        oboe::convertToText(stream_->getAudioApi()),
        sampleRate_,
        channelCount_,
        framesPerBurst_,
        stream_->getBufferCapacityInFrames(),
        bufferSizeFrames_,
        oboe::convertToText(stream_->getPerformanceMode()),
        oboe::convertToText(stream_->getSharingMode()),
        stream_->getDeviceId());
  }

  int64_t start() {
    const EngineLifecycleState state = getLifecycleState();
    if ((state == EngineLifecycleState::Uninitialized ||
         state == EngineLifecycleState::Disposed) ||
        stream_ == nullptr) {
      throw std::runtime_error("Metronome engine is not initialized");
    }
    if (runningIntent_.load(std::memory_order_acquire)) {
      return runId_.load(std::memory_order_acquire);
    }

    readEvent_.store(writeEvent_.load(std::memory_order_acquire),
                     std::memory_order_release);
    renderedFrames_.store(0, std::memory_order_release);
    localRenderedFrames_ = 0;
    nextBeatFrame_ = 0.0;
    framesPerBeat_ = 0.0;
    nextBeatNumber_ = 1;
    clickOffset_ = -1;
    sequence_ = 0;
    audioCallbackCount_.store(0, std::memory_order_release);
    appliedConfigRevision_ = 0;
    appliedSignatureRevision_ = 0;
    const int64_t runId =
        runId_.fetch_add(1, std::memory_order_acq_rel) + 1;
    const int64_t streamGeneration =
        streamGeneration_.load(std::memory_order_acquire);
    static_cast<void>(streamGeneration);
    firstCallbackLogged_.store(false, std::memory_order_release);
    runningIntent_.store(true, std::memory_order_release);
    lifecycleState_.store(
        EngineLifecycleState::Starting, std::memory_order_release);
    METRONOME_LOG(
        "event=start_request engine=%lld streamGeneration=%lld run=%lld "
        "state=starting oboeStateBefore=%s",
        static_cast<long long>(engineInstanceId_),
        static_cast<long long>(streamGeneration),
        static_cast<long long>(runId),
        oboe::convertToText(stream_->getState()));
    const oboe::Result result = stream_->requestStart();
    if (result != oboe::Result::OK) {
      runningIntent_.store(false, std::memory_order_release);
      lifecycleState_.store(
          EngineLifecycleState::Failed, std::memory_order_release);
      throw std::runtime_error(
          std::string("Could not start native audio stream: ") +
          oboe::convertToText(result));
    }
    METRONOME_LOG(
        "event=start_result engine=%lld streamGeneration=%lld run=%lld "
        "result=%s oboeStateAfter=%s",
        static_cast<long long>(engineInstanceId_),
        static_cast<long long>(streamGeneration),
        static_cast<long long>(runId),
        oboe::convertToText(result),
        oboe::convertToText(stream_->getState()));
    return runId;
  }

  std::array<int64_t, 2> stop() {
    runningIntent_.store(false, std::memory_order_release);
    lifecycleState_.store(
        EngineLifecycleState::Stopping, std::memory_order_release);
    METRONOME_LOG(
        "event=stop_request engine=%lld streamGeneration=%lld run=%lld "
        "audioCallbacks=%lld",
        static_cast<long long>(engineInstanceId_),
        static_cast<long long>(
            streamGeneration_.load(std::memory_order_acquire)),
        static_cast<long long>(runId_.load(std::memory_order_acquire)),
        static_cast<long long>(
            audioCallbackCount_.load(std::memory_order_acquire)));
    if (stream_ != nullptr) {
      stream_->requestStop();
    }
    lifecycleState_.store(
        stream_ == nullptr ? EngineLifecycleState::Uninitialized
                           : EngineLifecycleState::Stopped,
        std::memory_order_release);
    const int64_t frames = renderedFrames_.load(std::memory_order_acquire);
    int64_t xRuns = 0;
    if (stream_ != nullptr) {
      const auto result = stream_->getXRunCount();
      if (result) {
        xRuns = result.value();
      }
    }
    return {frames, xRuns};
  }

  void dispose() {
    runningIntent_.store(false, std::memory_order_release);
    activeStream_.store(nullptr, std::memory_order_release);
    const int64_t generation =
        streamGeneration_.load(std::memory_order_acquire);
    static_cast<void>(generation);
    if (stream_ != nullptr) {
      METRONOME_LOG(
          "event=close_request engine=%lld streamGeneration=%lld "
          "oboeState=%s audioCallbacks=%lld",
          static_cast<long long>(engineInstanceId_),
          static_cast<long long>(generation),
          oboe::convertToText(stream_->getState()),
          static_cast<long long>(
              audioCallbackCount_.load(std::memory_order_acquire)));
      stream_->requestStop();
      stream_->close();
      stream_.reset();
    }
    regularClick_.clear();
    accentClick_.clear();
    sampleRate_ = 0;
    channelCount_ = 0;
    framesPerBurst_ = 0;
    bufferSizeFrames_ = 0;
    lifecycleState_.store(
        EngineLifecycleState::Uninitialized, std::memory_order_release);
  }

  void setBpm(int32_t bpm) {
    if (bpm < kMinimumBpm || bpm > kMaximumBpm) {
      throw std::invalid_argument("BPM is outside the supported range");
    }
    bpm_.store(bpm, std::memory_order_relaxed);
    configRevision_.fetch_add(1, std::memory_order_release);
  }

  void setTimeSignature(int32_t beatsPerMeasure, int32_t beatUnit) {
    if (beatsPerMeasure <= 0 || (beatUnit != 4 && beatUnit != 8)) {
      throw std::invalid_argument("Unsupported metronome time signature");
    }
    beatsPerMeasure_.store(beatsPerMeasure, std::memory_order_relaxed);
    beatUnit_.store(beatUnit, std::memory_order_relaxed);
    signatureRevision_.fetch_add(1, std::memory_order_release);
    configRevision_.fetch_add(1, std::memory_order_release);
  }

  void setVolume(float volume) {
    if (!std::isfinite(volume) || volume < 0.0F || volume > 1.0F) {
      throw std::invalid_argument("Volume must be between zero and one");
    }
    volume_.store(volume, std::memory_order_release);
  }

  void setAccentEnabled(bool enabled) {
    accentEnabled_.store(enabled, std::memory_order_release);
  }

  const char* getAudioApi() const {
    if (stream_ == nullptr) {
      return "unavailable";
    }
    return oboe::convertToText(stream_->getAudioApi());
  }

  int64_t getEngineInstanceId() const { return engineInstanceId_; }
  int64_t getStreamGeneration() const {
    return streamGeneration_.load(std::memory_order_acquire);
  }
  EngineLifecycleState getLifecycleState() const {
    return lifecycleState_.load(std::memory_order_acquire);
  }
  int32_t getSampleRate() const { return sampleRate_; }
  int32_t getFramesPerBurst() const { return framesPerBurst_; }
  int32_t getBufferSizeFrames() const { return bufferSizeFrames_; }

  oboe::DataCallbackResult onAudioReady(
      oboe::AudioStream*,
      void* audioData,
      int32_t numFrames) override {
    auto* output = static_cast<int16_t*>(audioData);
    audioCallbackCount_.fetch_add(1, std::memory_order_relaxed);
    const int32_t sampleCount = numFrames * channelCount_;
    std::fill(output, output + sampleCount, 0);
    if (!runningIntent_.load(std::memory_order_acquire)) {
      return oboe::DataCallbackResult::Continue;
    }
    if (!firstCallbackLogged_.exchange(true, std::memory_order_acq_rel)) {
      lifecycleState_.store(
          EngineLifecycleState::Running, std::memory_order_release);
      METRONOME_LOG(
          "event=first_audio_callback engine=%lld streamGeneration=%lld "
          "run=%lld frames=%d",
          static_cast<long long>(engineInstanceId_),
          static_cast<long long>(
              streamGeneration_.load(std::memory_order_acquire)),
          static_cast<long long>(runId_.load(std::memory_order_acquire)),
          numFrames);
    }

    applyConfiguration();
    const float volume = volume_.load(std::memory_order_acquire);
    for (int32_t frame = 0; frame < numFrames; ++frame) {
      if (static_cast<double>(localRenderedFrames_) + 0.5 >= nextBeatFrame_) {
        const int32_t beatNumber = nextBeatNumber_;
        const bool accented =
            accentEnabled_.load(std::memory_order_acquire) &&
            beatNumber == 1;
        clickIsAccented_ = accented;
        clickOffset_ = 0;
        ++sequence_;
        queueBeat(
            runId_.load(std::memory_order_acquire),
            sequence_,
            beatNumber,
            accented,
            localRenderedFrames_);
        const int32_t beats =
            beatsPerMeasure_.load(std::memory_order_relaxed);
        nextBeatNumber_ = beatNumber >= beats ? 1 : beatNumber + 1;
        nextBeatFrame_ += framesPerBeat_;
      }

      int16_t sample = 0;
      if (clickOffset_ >= 0) {
        const auto& click = clickIsAccented_ ? accentClick_ : regularClick_;
        if (static_cast<size_t>(clickOffset_) < click.size()) {
          const double scaled = click[clickOffset_] * volume;
          sample = static_cast<int16_t>(std::clamp(
              std::llround(scaled),
              static_cast<long long>(INT16_MIN),
              static_cast<long long>(INT16_MAX)));
          ++clickOffset_;
        } else {
          clickOffset_ = -1;
        }
      }
      for (int32_t channel = 0; channel < channelCount_; ++channel) {
        output[frame * channelCount_ + channel] = sample;
      }
      ++localRenderedFrames_;
    }
    renderedFrames_.store(localRenderedFrames_, std::memory_order_release);
    return oboe::DataCallbackResult::Continue;
  }

  void onErrorBeforeClose(
      oboe::AudioStream* audioStream,
      oboe::Result error) override {
    const bool accepted =
        activeStream_.load(std::memory_order_acquire) == audioStream;
    static_cast<void>(accepted);
    static_cast<void>(error);
    METRONOME_LOG(
        "event=error_before_close engine=%lld streamGeneration=%lld "
        "run=%lld accepted=%d error=%s disconnected=%d audioCallbacks=%lld",
        static_cast<long long>(engineInstanceId_),
        static_cast<long long>(
            streamGeneration_.load(std::memory_order_acquire)),
        static_cast<long long>(runId_.load(std::memory_order_acquire)),
        accepted ? 1 : 0,
        oboe::convertToText(error),
        error == oboe::Result::ErrorDisconnected ? 1 : 0,
        static_cast<long long>(
            audioCallbackCount_.load(std::memory_order_acquire)));
  }

  void onErrorAfterClose(
      oboe::AudioStream* audioStream,
      oboe::Result error) override {
    const bool accepted =
        activeStream_.load(std::memory_order_acquire) == audioStream;
    const int64_t streamGeneration =
        streamGeneration_.load(std::memory_order_acquire);
    METRONOME_LOG(
        "event=error_after_close engine=%lld streamGeneration=%lld "
        "run=%lld accepted=%d error=%s disconnected=%d audioCallbacks=%lld",
        static_cast<long long>(engineInstanceId_),
        static_cast<long long>(streamGeneration),
        static_cast<long long>(runId_.load(std::memory_order_acquire)),
        accepted ? 1 : 0,
        oboe::convertToText(error),
        error == oboe::Result::ErrorDisconnected ? 1 : 0,
        static_cast<long long>(
            audioCallbackCount_.load(std::memory_order_acquire)));
    if (!accepted) {
      return;
    }
    runningIntent_.store(false, std::memory_order_release);
    lifecycleState_.store(
        EngineLifecycleState::Failed, std::memory_order_release);
    pendingErrorRunId_.store(
        runId_.load(std::memory_order_acquire), std::memory_order_release);
    pendingErrorStreamGeneration_.store(
        streamGeneration, std::memory_order_release);
    pendingError_.store(
        static_cast<int32_t>(error), std::memory_order_release);
  }

 private:
  static void validateConfig(
      int32_t bpm,
      int32_t beatsPerMeasure,
      int32_t beatUnit,
      float volume) {
    if (bpm < kMinimumBpm || bpm > kMaximumBpm) {
      throw std::invalid_argument("BPM is outside the supported range");
    }
    if (beatsPerMeasure <= 0 || (beatUnit != 4 && beatUnit != 8)) {
      throw std::invalid_argument("Unsupported metronome time signature");
    }
    if (!std::isfinite(volume) || volume < 0.0F || volume > 1.0F) {
      throw std::invalid_argument("Volume must be between zero and one");
    }
  }

  void applyConfiguration() {
    const uint64_t revision =
        configRevision_.load(std::memory_order_acquire);
    if (revision == appliedConfigRevision_) {
      return;
    }
    const int32_t bpm = bpm_.load(std::memory_order_relaxed);
    const int32_t beatUnit = beatUnit_.load(std::memory_order_relaxed);
    const double newFramesPerBeat =
        static_cast<double>(sampleRate_) * 60.0 * 4.0 /
        (static_cast<double>(bpm) * beatUnit);
    if (framesPerBeat_ > 0.0 &&
        nextBeatFrame_ > static_cast<double>(localRenderedFrames_)) {
      const double remainingFraction = std::clamp(
          (nextBeatFrame_ - localRenderedFrames_) / framesPerBeat_,
          0.0,
          1.0);
      nextBeatFrame_ =
          localRenderedFrames_ + remainingFraction * newFramesPerBeat;
    }
    framesPerBeat_ = newFramesPerBeat;

    const uint64_t signatureRevision =
        signatureRevision_.load(std::memory_order_acquire);
    if (signatureRevision != appliedSignatureRevision_) {
      nextBeatNumber_ = 1;
      appliedSignatureRevision_ = signatureRevision;
    }
    appliedConfigRevision_ = revision;
  }

  void queueBeat(
      int64_t runId,
      int32_t sequence,
      int32_t beatNumber,
      bool accented,
      int64_t audioFramePosition) {
    const size_t write = writeEvent_.load(std::memory_order_relaxed);
    const size_t next = (write + 1) % kEventCapacity;
    if (next == readEvent_.load(std::memory_order_acquire)) {
      return;
    }
    beatEvents_[write] = BeatEvent{
        runId,
        streamGeneration_.load(std::memory_order_relaxed),
        appliedConfigRevision_,
        sequence,
        beatNumber,
        accented,
        audioFramePosition,
        monotonicNanos(),
    };
    writeEvent_.store(next, std::memory_order_release);
  }

  void dispatchLoop() {
    JNIEnv* env = nullptr;
    if (javaVm_->AttachCurrentThread(&env, nullptr) != JNI_OK ||
        env == nullptr) {
      return;
    }
    while (!shutdownDispatcher_.load(std::memory_order_acquire)) {
      bool dispatched = false;
      size_t read = readEvent_.load(std::memory_order_relaxed);
      const size_t write = writeEvent_.load(std::memory_order_acquire);
      while (read != write) {
        const BeatEvent event = beatEvents_[read];
        read = (read + 1) % kEventCapacity;
        readEvent_.store(read, std::memory_order_release);
        if (event.configRevision !=
            configRevision_.load(std::memory_order_acquire)) {
          continue;
        }
        env->CallVoidMethod(
            owner_,
            beatMethod_,
            static_cast<jlong>(event.runId),
            static_cast<jlong>(event.streamGeneration),
            static_cast<jint>(event.sequence),
            static_cast<jint>(event.beatNumber),
            static_cast<jboolean>(event.accented),
            static_cast<jlong>(event.audioFramePosition),
            static_cast<jlong>(event.callbackTimeNanos));
        if (env->ExceptionCheck()) {
          env->ExceptionClear();
        }
        dispatched = true;
      }

      const int32_t errorCode =
          pendingError_.exchange(0, std::memory_order_acq_rel);
      if (errorCode != 0) {
        const auto result = static_cast<oboe::Result>(errorCode);
        const char* detail = oboe::convertToText(result);
        const jstring code = env->NewStringUTF("audio_stream");
        const jstring message = env->NewStringUTF(detail);
        env->CallVoidMethod(
            owner_,
            errorMethod_,
            static_cast<jlong>(
                pendingErrorRunId_.load(std::memory_order_acquire)),
            static_cast<jlong>(
                pendingErrorStreamGeneration_.load(
                    std::memory_order_acquire)),
            code,
            message);
        env->DeleteLocalRef(code);
        env->DeleteLocalRef(message);
        if (env->ExceptionCheck()) {
          env->ExceptionClear();
        }
        dispatched = true;
      }
      if (!dispatched) {
        std::this_thread::sleep_for(std::chrono::milliseconds(2));
      }
    }
    javaVm_->DetachCurrentThread();
  }

  JavaVM* javaVm_;
  jobject owner_;
  const int64_t engineInstanceId_;
  jmethodID beatMethod_ = nullptr;
  jmethodID errorMethod_ = nullptr;
  std::shared_ptr<oboe::AudioStream> stream_;
  std::vector<int16_t> regularClick_;
  std::vector<int16_t> accentClick_;
  std::array<BeatEvent, kEventCapacity> beatEvents_{};
  std::atomic<size_t> writeEvent_{0};
  std::atomic<size_t> readEvent_{0};
  std::atomic<bool> shutdownDispatcher_{false};
  std::thread dispatcher_;
  std::atomic<EngineLifecycleState> lifecycleState_{
      EngineLifecycleState::Uninitialized};
  std::atomic<bool> runningIntent_{false};
  std::atomic<bool> firstCallbackLogged_{false};
  std::atomic<oboe::AudioStream*> activeStream_{nullptr};
  std::atomic<int64_t> streamGeneration_{0};
  std::atomic<int64_t> runId_{0};
  std::atomic<int64_t> renderedFrames_{0};
  std::atomic<int64_t> audioCallbackCount_{0};
  std::atomic<int32_t> bpm_{120};
  std::atomic<int32_t> beatsPerMeasure_{4};
  std::atomic<int32_t> beatUnit_{4};
  std::atomic<float> volume_{0.65F};
  std::atomic<bool> accentEnabled_{true};
  std::atomic<uint64_t> configRevision_{0};
  std::atomic<uint64_t> signatureRevision_{0};
  std::atomic<int32_t> pendingError_{0};
  std::atomic<int64_t> pendingErrorRunId_{0};
  std::atomic<int64_t> pendingErrorStreamGeneration_{0};
  int32_t sampleRate_ = 0;
  int32_t channelCount_ = 0;
  int32_t framesPerBurst_ = 0;
  int32_t bufferSizeFrames_ = 0;
  int64_t localRenderedFrames_ = 0;
  double nextBeatFrame_ = 0.0;
  double framesPerBeat_ = 0.0;
  int32_t nextBeatNumber_ = 1;
  int32_t sequence_ = 0;
  int32_t clickOffset_ = -1;
  bool clickIsAccented_ = false;
  uint64_t appliedConfigRevision_ = 0;
  uint64_t appliedSignatureRevision_ = 0;
};

NativeMetronome* fromHandle(jlong handle) {
  if (handle == 0) {
    throw std::invalid_argument("Native metronome handle is closed");
  }
  return reinterpret_cast<NativeMetronome*>(handle);
}

std::vector<uint8_t> byteArrayToVector(JNIEnv* env, jbyteArray array) {
  if (array == nullptr) {
    throw std::invalid_argument("Click asset bytes are missing");
  }
  const jsize length = env->GetArrayLength(array);
  std::vector<uint8_t> bytes(static_cast<size_t>(length));
  env->GetByteArrayRegion(
      array,
      0,
      length,
      reinterpret_cast<jbyte*>(bytes.data()));
  return bytes;
}

void throwJava(JNIEnv* env, const std::exception& error) {
  const jclass exceptionClass =
      env->FindClass("java/lang/IllegalStateException");
  if (exceptionClass != nullptr) {
    env->ThrowNew(exceptionClass, error.what());
    env->DeleteLocalRef(exceptionClass);
  }
}

}  // namespace

extern "C" JNIEXPORT jlong JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeCreate(
    JNIEnv* env,
    jobject owner) {
  try {
    JavaVM* javaVm = nullptr;
    if (env->GetJavaVM(&javaVm) != JNI_OK || javaVm == nullptr) {
      throw std::runtime_error("Could not access the Android Java VM");
    }
    return reinterpret_cast<jlong>(
        new NativeMetronome(javaVm, env, owner));
  } catch (const std::exception& error) {
    throwJava(env, error);
    return 0;
  }
}

extern "C" JNIEXPORT void JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeInitialize(
    JNIEnv* env,
    jobject,
    jlong handle,
    jbyteArray regularWav,
    jbyteArray accentWav,
    jint bpm,
    jint beatsPerMeasure,
    jint beatUnit,
    jfloat volume,
    jboolean accentEnabled) {
  try {
    fromHandle(handle)->initialize(
        byteArrayToVector(env, regularWav),
        byteArrayToVector(env, accentWav),
        bpm,
        beatsPerMeasure,
        beatUnit,
        volume,
        accentEnabled);
  } catch (const std::exception& error) {
    throwJava(env, error);
  }
}

extern "C" JNIEXPORT jlong JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeStart(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    return fromHandle(handle)->start();
  } catch (const std::exception& error) {
    throwJava(env, error);
    return 0;
  }
}

extern "C" JNIEXPORT jlongArray JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeStop(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    const auto report = fromHandle(handle)->stop();
    const jlong values[] = {report[0], report[1]};
    jlongArray result = env->NewLongArray(2);
    env->SetLongArrayRegion(result, 0, 2, values);
    return result;
  } catch (const std::exception& error) {
    throwJava(env, error);
    return nullptr;
  }
}

extern "C" JNIEXPORT void JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeSetBpm(
    JNIEnv* env,
    jobject,
    jlong handle,
    jint bpm) {
  try {
    fromHandle(handle)->setBpm(bpm);
  } catch (const std::exception& error) {
    throwJava(env, error);
  }
}

extern "C" JNIEXPORT void JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeSetTimeSignature(
    JNIEnv* env,
    jobject,
    jlong handle,
    jint beatsPerMeasure,
    jint beatUnit) {
  try {
    fromHandle(handle)->setTimeSignature(beatsPerMeasure, beatUnit);
  } catch (const std::exception& error) {
    throwJava(env, error);
  }
}

extern "C" JNIEXPORT void JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeSetVolume(
    JNIEnv* env,
    jobject,
    jlong handle,
    jfloat volume) {
  try {
    fromHandle(handle)->setVolume(volume);
  } catch (const std::exception& error) {
    throwJava(env, error);
  }
}

extern "C" JNIEXPORT void JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeSetAccentEnabled(
    JNIEnv* env,
    jobject,
    jlong handle,
    jboolean enabled) {
  try {
    fromHandle(handle)->setAccentEnabled(enabled);
  } catch (const std::exception& error) {
    throwJava(env, error);
  }
}

extern "C" JNIEXPORT jstring JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeGetLifecycleState(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    return env->NewStringUTF(
        lifecycleStateName(fromHandle(handle)->getLifecycleState()));
  } catch (const std::exception& error) {
    throwJava(env, error);
    return nullptr;
  }
}

extern "C" JNIEXPORT jlong JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeGetEngineInstanceId(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    return fromHandle(handle)->getEngineInstanceId();
  } catch (const std::exception& error) {
    throwJava(env, error);
    return 0;
  }
}

extern "C" JNIEXPORT jlong JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeGetStreamGeneration(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    return fromHandle(handle)->getStreamGeneration();
  } catch (const std::exception& error) {
    throwJava(env, error);
    return 0;
  }
}

extern "C" JNIEXPORT jstring JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeGetAudioApi(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    return env->NewStringUTF(fromHandle(handle)->getAudioApi());
  } catch (const std::exception& error) {
    throwJava(env, error);
    return nullptr;
  }
}

extern "C" JNIEXPORT jint JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeGetSampleRate(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    return fromHandle(handle)->getSampleRate();
  } catch (const std::exception& error) {
    throwJava(env, error);
    return 0;
  }
}

extern "C" JNIEXPORT jint JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeGetFramesPerBurst(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    return fromHandle(handle)->getFramesPerBurst();
  } catch (const std::exception& error) {
    throwJava(env, error);
    return 0;
  }
}

extern "C" JNIEXPORT jint JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeGetBufferSizeFrames(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    return fromHandle(handle)->getBufferSizeFrames();
  } catch (const std::exception& error) {
    throwJava(env, error);
    return 0;
  }
}

extern "C" JNIEXPORT void JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeDispose(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    fromHandle(handle)->dispose();
  } catch (const std::exception& error) {
    throwJava(env, error);
  }
}

extern "C" JNIEXPORT void JNICALL
Java_dev_gundev_tunathic_audio_NativeMetronomeEngine_nativeDestroy(
    JNIEnv* env,
    jobject,
    jlong handle) {
  try {
    delete fromHandle(handle);
  } catch (const std::exception& error) {
    throwJava(env, error);
  }
}
