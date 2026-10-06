#!/usr/bin/env bash
#
# Сверяет ключ Amplitude в сборке с ключом на Railway.
#
# Зачем: релиз 2.5.1 уехал в App Store со старым ключом. Папку под релиз завели
# через git worktree, а новый ключ две недели лежал только в рабочей копии и в
# историю не попал. Worktree выложил файл из коммита, и все события
# пользователей две недели уходили в старый проект.
#
# Источник правды — Railway: тем же ключом бэкенд чистит профиль при удалении
# аккаунта, так что приложение обязано писать в тот же проект.
#
# Использование: scripts/check_amplitude_key.sh prod|dev|local
# Пропустить проверку: AMPLITUDE_CHECK_SKIP=1

set -euo pipefail

env_name="${1:-}"
case "$env_name" in
  prod)
    asset="assets/environment_values/environment.json"
    railway_env="production"
    ;;
  dev)
    asset="assets/environment_values/environment.dev.json"
    railway_env="development"
    ;;
  local)
    asset="assets/environment_values/environment.local.json"
    railway_env=""
    ;;
  *)
    echo "Использование: $0 prod|dev|local" >&2
    exit 2
    ;;
esac

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

if [[ "${AMPLITUDE_CHECK_SKIP:-}" == "1" ]]; then
  echo "Проверка ключа Amplitude пропущена (AMPLITUDE_CHECK_SKIP=1)."
  exit 0
fi

read_key() {
  python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("amplitudekey",""))' "$1"
}

short() {
  if [[ -z "$1" ]]; then echo "пусто"; else echo "${1:0:8}…"; fi
}

key="$(read_key "$asset")"

# У local ключа нет: аналитика выключена, сверять не с чем.
if [[ "$env_name" == "local" ]]; then
  if [[ -n "$key" ]]; then
    echo "В $asset прописан ключ $(short "$key"), хотя у local аналитика выключена." >&2
    exit 1
  fi
  echo "Окружение local: аналитика выключена, ключ не нужен."
  exit 0
fi

if [[ -z "$key" ]]; then
  echo "В $asset нет ключа Amplitude. Аналитика в сборке будет выключена." >&2
  exit 1
fi

backend="${MIRRA_BACKEND_DIR:-$(cd "$repo/.." && pwd)/mirra_backend-main}"
if [[ ! -d "$backend" ]]; then
  echo "Не нашлась папка бэкенда: $backend" >&2
  echo "Укажите её через MIRRA_BACKEND_DIR, оттуда читается ключ Railway." >&2
  exit 1
fi

# railway читает переменные только из привязанной папки, поэтому идём в бэкенд.
expected="$(
  cd "$backend" &&
    railway variables --json --environment "$railway_env" --service web 2>/dev/null |
    python3 -c 'import json,sys; print(json.load(sys.stdin).get("AMPLITUDE_API_KEY",""))' 2>/dev/null
)" || expected=""

if [[ -z "$expected" ]]; then
  echo "Не удалось прочитать ключ Amplitude с Railway ($railway_env)." >&2
  echo "Войдите через railway login или соберите с AMPLITUDE_CHECK_SKIP=1." >&2
  exit 1
fi

if [[ "$key" != "$expected" ]]; then
  echo "Ключ Amplitude не совпадает с Railway." >&2
  echo "  окружение:  $env_name" >&2
  echo "  файл:       $asset" >&2
  echo "  в сборке:   $(short "$key")" >&2
  echo "  на Railway: $(short "$expected")" >&2
  echo "События уйдут в чужой проект. Обновите ключ в файле или проверьте ветку." >&2
  exit 1
fi

# Та самая причина, по которой ключ разъехался: правка живёт только локально,
# а сборка из другой ветки или worktree возьмёт версию из коммита.
if ! git diff --quiet -- assets/environment_values/ 2>/dev/null; then
  echo "Внимание: правки в assets/environment_values не закоммичены."
  echo "Сборка из другой ветки или worktree их не увидит."
fi

echo "Ключ Amplitude сходится с Railway ($env_name, $(short "$key"))."
