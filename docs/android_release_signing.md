# Android Release Signing

Tunathic release builds intentionally fail until authorized local upload-key
credentials are configured. No real keystore or credential belongs in Git.

## Key roles

- **Debug key:** Automatically used for development builds. It is widely known,
  replaceable, and must never sign a Play upload.
- **Upload key:** Controlled by the developer. It signs the AAB sent to Play and
  proves that an upload is authorized. Back it up securely.
- **App signing key:** Signs APKs delivered to users. With Play App Signing,
  Google protects this key and signs the APKs generated from the uploaded AAB.

For a new Play-only app, the practical recommendation is a developer-controlled
upload key plus a distinct Google-generated app signing key. Google currently
recommends distinct keys and supports upload-key reset when Play App Signing is
used. The user must make this irreversible distribution decision in Play
Console.

Official source:
https://support.google.com/googleplay/android-developer/answer/9842756

## Repository configuration

`android/app/build.gradle.kts` reads `android/key.properties` only when it
exists and contains all required values. Debug/profile builds do not need it.
Any release task fails at `preReleaseBuild` if credentials or the referenced
keystore are missing.

1. After explicit authorization, create the upload keystore in a secure folder
   outside the repository and outside cloud-synced source folders.
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Set `storeFile` to an absolute local path, plus local `storePassword`,
   `keyAlias`, and `keyPassword`.
4. Build the AAB and verify its signer before upload.

The `.gitignore` and `android/.gitignore` exclude `key.properties`, `.jks`,
`.keystore`, and `.p12` material. Always confirm with `git status` before
committing.

## Authorized key creation follow-up

Do not run this until the user approves the final alias, storage location, and
backup arrangement. Use Android Studio's Generate Signed Bundle workflow or
`keytool` with an RSA key of at least 2,048 bits, a long validity period, and
strong unique secrets. Do not paste passwords into shell history.

Record privately:

- keystore path and encrypted backups;
- alias;
- creation date and owner;
- upload certificate SHA-256;
- recovery procedure; and
- Play Console application/package association.

Inspect the certificate without exposing passwords in logs:

```text
keytool -list -v -keystore C:\secure\tunathic-upload.jks -alias tunathic-upload
```

After building, use Android build tools:

```text
apksigner verify --verbose --print-certs build\app\outputs\flutter-apk\app-release.apk
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab
```

Calculate and retain a SHA-256 artifact hash with PowerShell:

```text
Get-FileHash build\app\outputs\bundle\release\app-release.aab -Algorithm SHA256
```

## Backup and loss implications

Keep at least two encrypted backups in physically or administratively separate
locations, with recovery instructions available to the publisher. Losing an
upload key can interrupt releases but Play App Signing provides an upload-key
reset path. Losing a self-managed app signing key can permanently prevent
updates; this is a central reason to prefer Google-managed app signing for a
new Play-only product.
