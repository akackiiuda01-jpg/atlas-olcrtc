package database

import (
	"database/sql"

	_ "github.com/mattn/go-sqlite3"
)

var DB *sql.DB

func Init(path string) error {
	db, err := sql.Open("sqlite3", path)
	if err != nil {
		return err
	}

	_, err = db.Exec(`
CREATE TABLE IF NOT EXISTS devices (
	device_id TEXT PRIMARY KEY,
	expires_at TEXT,
	blocked INTEGER DEFAULT 0
);
`)
	if err != nil {
		return err
	}

	DB = db
	return nil
}

func DeviceExists(deviceID string) (bool, error) {
	var count int

	err := DB.QueryRow(
		"SELECT COUNT(*) FROM devices WHERE device_id = ?",
		deviceID,
	).Scan(&count)

	if err != nil {
		return false, err
	}

	return count > 0, nil
}

func RegisterDevice(deviceID string) error {
	_, err := DB.Exec(
		"INSERT INTO devices(device_id) VALUES(?)",
		deviceID,
	)

	return err
}
