#!/usr/bin/env bash
#
# Сборка IPA под App Store с проверкой ключа Amplitude.
#
# Использование: scripts/build_ipa.sh prod|dev
#
# Готовый файл кладётся рядом с остальными:
#   build/ios/ipa/MiRRA-<версия>-<билд>-<окружение>.ipa

set -euo pipefail

env_name="${1:-}"
if [[ "$env_name" != "prod" && "$env_name" != "dev" ]]; then
  echo "Использование: $0 prod|dev" >&2
  exit 2
fi

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

# Сначала ключ, потом сборка: падать десять минут спустя незачем.
"$repo/scripts/check_amplitude_key.sh" "$env_name"

flutter build ipa --release --dart-define=APP_ENV="$env_name"

version_line="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"
version="${version_line%%+*}"
build_number="${version_line##*+}"
target="build/ios/ipa/MiRRA-$version-$build_number-$env_name.ipa"

mv "build/ios/ipa/MiRRA.ipa" "$target"
echo "Готово: $target"
