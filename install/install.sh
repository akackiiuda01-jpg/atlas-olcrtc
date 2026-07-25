#!/bin/bash
set -e

REPO="akackiiuda01-jpg/atlas-olcrtc"
BRANCH="atlas-core"

echo "===================================="
echo "      AtlasD Installer"
echo "===================================="

if [ "$EUID" -ne 0 ]; then
    echo "Запусти установщик от root."
    exit 1
fi

echo "[1/8] Проверка системы..."
command -v curl >/dev/null || {
    apt update
    apt install -y curl
}

echo "[2/8] Создание каталогов..."
mkdir -p /etc/atlasd
mkdir -p /var/lib/atlasd

echo "[3/8] Загрузка бинарника..."
curl -L "https://raw.githubusercontent.com/$REPO/$BRANCH/atlasd" \
    -o /usr/local/bin/atlasd

chmod +x /usr/local/bin/atlasd

echo "[4/8] Загрузка конфигурации..."
curl -L "https://raw.githubusercontent.com/$REPO/$BRANCH/install/config.yaml" \
    -o /etc/atlasd/config.yaml

echo "[5/8] Загрузка systemd..."
curl -L "https://raw.githubusercontent.com/$REPO/$BRANCH/install/atlasd.service" \
    -o /etc/systemd/system/atlasd.service

echo "[6/8] Обновление systemd..."
systemctl daemon-reload

echo "[7/8] Включение автозапуска..."
systemctl enable atlasd

echo "[8/8] Запуск..."
systemctl restart atlasd

echo
echo "===================================="
echo "AtlasD установлен."
echo
echo "Конфиг:"
echo "  /etc/atlasd/config.yaml"
echo
echo "Проверка:"
echo "  systemctl status atlasd"
echo
echo "Логи:"
echo "  journalctl -u atlasd -f"
echo "===================================="
