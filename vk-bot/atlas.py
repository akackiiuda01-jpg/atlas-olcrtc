import yaml
import subprocess

from config import ATLAS_CONFIG, ATLAS_SERVICE


def load_config():
    with open(ATLAS_CONFIG, "r") as f:
        return yaml.safe_load(f)


def save_config(cfg):
    with open(ATLAS_CONFIG, "w") as f:
        yaml.safe_dump(cfg, f, default_flow_style=False, sort_keys=False)


def get_key():
    cfg = load_config()
    return cfg["crypto"]["key"]


def get_room():
    cfg = load_config()
    return cfg["room"]["id"]


def set_room(room_id):
    cfg = load_config()

    cfg["room"]["id"] = room_id

    save_config(cfg)

    subprocess.run(
        ["systemctl", "restart", ATLAS_SERVICE],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def status():
    result = subprocess.run(
        ["systemctl", "is-active", ATLAS_SERVICE],
        capture_output=True,
        text=True,
    )

    return result.stdout.strip()
