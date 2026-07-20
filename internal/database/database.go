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
