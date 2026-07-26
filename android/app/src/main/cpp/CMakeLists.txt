cmake_minimum_required(VERSION 3.22.1)

project(tunathic_metronome LANGUAGES CXX)

find_package(oboe REQUIRED CONFIG)

add_library(
    tunathic_metronome
    SHARED
    metronome_engine.cpp
)

target_compile_features(tunathic_metronome PRIVATE cxx_std_17)
target_compile_options(
    tunathic_metronome
    PRIVATE
    -Wall
    -Wextra
    -Werror
)

target_link_libraries(
    tunathic_metronome
    PRIVATE
    oboe::oboe
    android
    log
)
