#!/usr/bin/env bash

# Creates the one upload key used by GitHub Actions to sign every APK. Run this
# once on a trusted machine, back up the resulting file, and then add the
# printed values as GitHub Actions secrets.
set -euo pipefail

keystore_path="${1:-android/lego-tracker-upload.jks}"
key_alias="${2:-lego-tracker}"

if [ -e "$keystore_path" ]; then
  echo "Refusing to overwrite existing keystore: $keystore_path" >&2
  exit 1
fi

mkdir -p "$(dirname "$keystore_path")"
read -r -s -p "Keystore password: " store_password
echo
read -r -s -p "Confirm keystore password: " store_password_confirmation
echo

if [ "$store_password" != "$store_password_confirmation" ]; then
  echo "Passwords do not match." >&2
  exit 1
fi

if [ "${#store_password}" -lt 6 ]; then
  echo "The password must have at least six characters." >&2
  exit 1
fi

keytool -genkeypair \
  -keystore "$keystore_path" \
  -storepass "$store_password" \
  -alias "$key_alias" \
  -keypass "$store_password" \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000 \
  -dname "CN=Lego Tracker"

echo
echo "Add these GitHub Actions secrets (keep the keystore backed up):"
echo "ANDROID_KEYSTORE_BASE64=$(base64 < "$keystore_path" | tr -d '\n')"
echo "ANDROID_KEYSTORE_PASSWORD=$store_password"
echo "ANDROID_KEY_ALIAS=$key_alias"
echo "ANDROID_KEY_PASSWORD=$store_password"
