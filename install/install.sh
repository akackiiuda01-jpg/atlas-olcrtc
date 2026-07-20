#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "===================================="
echo "      AtlasD Installer"
echo "===================================="

if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: запусти установщик от root."
    exit 1
fi

echo "[1/7] Создание каталогов..."
mkdir -p /etc/atlasd
mkdir -p /var/lib/atlasd

echo "[2/7] Установка бинарника..."
install -m 755 "$SCRIPT_DIR/../atlasd" /usr/local/bin/atlasd

echo "[3/7] Установка конфигурации..."
if [ ! -f /etc/atlasd/config.yaml ]; then
    cp "$SCRIPT_DIR/config.template" /etc/atlasd/config.yaml
fi

echo "[4/7] Установка systemd..."
cp "$SCRIPT_DIR/atlasd.service" /etc/systemd/system/atlasd.service

echo "[5/7] Обновление systemd..."
systemctl daemon-reload

echo "[6/7] Включение автозапуска..."
systemctl enable atlasd

echo "[7/7] Запуск сервиса..."
