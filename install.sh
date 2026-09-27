#!/usr/bin/env bash
# GAMEPAD TEST PRO — установка на Steam Deck / Linux
#
# Использование (когда файлы уже на GitHub):
#   curl -fsSL https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПО/main/install.sh | bash
#
# Или локально:
#   bash install.sh
#
set -euo pipefail

# === ПОМЕНЯЙ НА СВОЙ РЕПО ПОСЛЕ ЗАГРУЗКИ НА GITHUB ===
REPO_USER="${GP_REPO_USER:-YOUR_GITHUB_USER}"
REPO_NAME="${GP_REPO_NAME:-gamepad-test-pro}"
REPO_BRANCH="${GP_REPO_BRANCH:-main}"
# =====================================================

RAW_BASE="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${REPO_BRANCH}"
INSTALL_DIR="${HOME}/Games/GamepadTestPro"
DESKTOP_FILE="${HOME}/.local/share/applications/gamepad-test-pro.desktop"
HTML_NAME="Gamepad_LAB_Ultimate.html"

echo "=== GAMEPAD TEST PRO — установка ==="

mkdir -p "$INSTALL_DIR"

download() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$out" "$url"
  else
    echo "Нужен curl или wget"; exit 1
  fi
}

# Если скрипт рядом с HTML (локальная папка) — копируем оттуда
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/${HTML_NAME}" ]]; then
  echo "→ Копирую локальный ${HTML_NAME}"
  cp -f "${SCRIPT_DIR}/${HTML_NAME}" "${INSTALL_DIR}/${HTML_NAME}"
else
  if [[ "$REPO_USER" == "YOUR_GITHUB_USER" ]]; then
    echo ""
    echo "Ошибка: укажи свой GitHub."
    echo "  export GP_REPO_USER=твой_ник"
    echo "  export GP_REPO_NAME=имя_репо"
    echo "  curl -fsSL https://raw.githubusercontent.com/\$GP_REPO_USER/\$GP_REPO_NAME/main/install.sh | bash"
    echo ""
    echo "Или скачай HTML вручную в ${INSTALL_DIR}/"
    exit 1
  fi
  echo "→ Скачиваю с GitHub: ${RAW_BASE}/${HTML_NAME}"
  download "${RAW_BASE}/${HTML_NAME}" "${INSTALL_DIR}/${HTML_NAME}"
fi

HTML_PATH="${INSTALL_DIR}/${HTML_NAME}"
if [[ ! -f "$HTML_PATH" ]]; then
  echo "Файл не найден: $HTML_PATH"; exit 1
fi

# Браузер: на SteamOS часто flatpak Firefox / Chrome
open_cmd=""
if command -v xdg-open >/dev/null 2>&1; then
  open_cmd="xdg-open"
elif command -v firefox >/dev/null 2>&1; then
  open_cmd="firefox"
elif command -v google-chrome >/dev/null 2>&1; then
  open_cmd="google-chrome"
elif command -v chromium-browser >/dev/null 2>&1; then
  open_cmd="chromium-browser"
else
  open_cmd="xdg-open"
fi

mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=GAMEPAD TEST PRO
Comment=Тестер геймпада: кнопки, стики, дрейф, игры
Exec=${open_cmd} ${HTML_PATH}
Icon=input-gaming
Terminal=false
Type=Application
Categories=Game;Utility;
Keywords=gamepad;controller;steamdeck;
EOF
chmod +x "$DESKTOP_FILE" 2>/dev/null || true

# Ярлык на рабочий стол (Desktop Mode)
DESKTOP_DIR="${HOME}/Desktop"
if [[ -d "$DESKTOP_DIR" ]]; then
  cp -f "$DESKTOP_FILE" "${DESKTOP_DIR}/gamepad-test-pro.desktop" 2>/dev/null || true
  chmod +x "${DESKTOP_DIR}/gamepad-test-pro.desktop" 2>/dev/null || true
fi

echo ""
echo "✓ Установлено: ${HTML_PATH}"
echo "✓ Ярлык:      ${DESKTOP_FILE}"
echo ""
echo "Запуск:"
echo "  ${open_cmd} \"${HTML_PATH}\""
echo "  или иконка «GAMEPAD TEST PRO» в меню / на рабочем столе"
echo ""
echo "На Steam Deck: Desktop Mode → открой ярлык (в Gaming Mode браузерный Gamepad API ограничен)."
echo ""

# Сразу открыть, если есть дисплей
if [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
  ${open_cmd} "${HTML_PATH}" >/dev/null 2>&1 &
  echo "→ Открываю в браузере…"
fi
