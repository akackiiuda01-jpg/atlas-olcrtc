#!/bin/bash
set -e

REPO="akackiiuda01-jpg/atlas-olcrtc"
BRANCH="atlas-core"
RAW="https://raw.githubusercontent.com/$REPO/$BRANCH"

echo "===================================="
echo "   Atlas + VK-Bot — единый установщик"
echo "===================================="

if [ "$EUID" -ne 0 ]; then
    echo "Запусти установщик от root (sudo)."
    exit 1
fi

echo "[1/12] Проверка системы..."
command -v curl >/dev/null || { apt update && apt install -y curl; }
command -v python3 >/dev/null || { apt update && apt install -y python3; }
python3 -m venv --help >/dev/null 2>&1 || apt install -y python3-venv
command -v openssl >/dev/null || apt install -y openssl

echo "[2/12] Создание каталогов..."
mkdir -p /etc/atlasd /var/lib/atlasd /opt/atlas-vk-bot

echo "[3/12] Загрузка бинарника AtlasD..."
curl -fsSL "$RAW/atlasd" -o /usr/local/bin/atlasd
chmod +x /usr/local/bin/atlasd

echo "[4/12] Загрузка конфигурации AtlasD..."
if [ ! -f /etc/atlasd/config.yaml ]; then
    curl -fsSL "$RAW/install/config.yaml" -o /etc/atlasd/config.yaml
else
    echo "  config.yaml уже существует — пропускаю."
fi

echo "[5/12] Генерация ключа шифрования (если не задан)..."
if [ -z "$(grep -oP '(?<=key: ").+(?=")' /etc/atlasd/config.yaml 2>/dev/null)" ]; then
    KEY=$(openssl rand -hex 32)
    sed -i "s/key: \"\"/key: \"$KEY\"/" /etc/atlasd/config.yaml
    echo "  Сгенерирован ключ: $KEY"
fi

if [ -z "$(grep -oP '(?<=id: ").+(?=")' /etc/atlasd/config.yaml 2>/dev/null)" ]; then
    read -rp "  Введи Room ID (URL комнаты Jitsi/WB Stream): " ROOM_ID < /dev/tty
    sed -i "s#id: \"\"#id: \"$ROOM_ID\"#" /etc/atlasd/config.yaml
fi

echo "[6/12] Загрузка systemd unit для AtlasD..."
curl -fsSL "$RAW/install/atlasd.service" -o /etc/systemd/system/atlasd.service

echo "[7/12] Загрузка файлов VK-бота..."
curl -fsSL "$RAW/vk-bot/bot.py" -o /opt/atlas-vk-bot/bot.py
curl -fsSL "$RAW/vk-bot/atlas.py" -o /opt/atlas-vk-bot/atlas.py
curl -fsSL "$RAW/vk-bot/config.py" -o /opt/atlas-vk-bot/config.py
curl -fsSL "$RAW/vk-bot/requirements.txt" -o /opt/atlas-vk-bot/requirements.txt
curl -fsSL "$RAW/vk-bot/service/atlas-vk-bot.service" -o /etc/systemd/system/atlas-vk-bot.service

echo "[8/12] Настройка Python venv для бота..."
python3 -m venv /opt/atlas-vk-bot/venv
/opt/atlas-vk-bot/venv/bin/pip install --quiet --upgrade pip
/opt/atlas-vk-bot/venv/bin/pip install --quiet -r /opt/atlas-vk-bot/requirements.txt

echo "[9/12] Настройка VK-бота..."
if grep -q "YOUR_VK_TOKEN" /opt/atlas-vk-bot/config.py 2>/dev/null; then
    read -rp "  Введи VK_TOKEN бота (токен сообщества/пользователя): " VK_TOKEN_INPUT < /dev/tty
    read -rp "  Введи твой VK ADMIN_ID (числовой ID твоей страницы): " ADMIN_ID_INPUT < /dev/tty
    sed -i "s/YOUR_VK_TOKEN/$VK_TOKEN_INPUT/" /opt/atlas-vk-bot/config.py
    sed -i "s/123456789/$ADMIN_ID_INPUT/" /opt/atlas-vk-bot/config.py
fi

echo "[10/12] Обновление systemd..."
systemctl daemon-reload

echo "[11/12] Включение автозапуска..."
systemctl enable atlasd atlas-vk-bot

echo "[12/12] Запуск сервисов..."
systemctl restart atlasd
systemctl restart atlas-vk-bot

echo
echo "===================================="
echo "Atlas + VK-Bot установлены."
echo
echo "AtlasD конфиг:   /etc/atlasd/config.yaml"
echo "VK-бот конфиг:   /opt/atlas-vk-bot/config.py"
echo
echo "Проверка:"
echo "  systemctl status atlasd"
echo "  systemctl status atlas-vk-bot"
echo
echo "Логи:"
echo "  journalctl -u atlasd -f"
echo "  journalctl -u atlas-vk-bot -f"
echo "===================================="
