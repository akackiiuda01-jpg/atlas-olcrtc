package database

import (
	"database/sql"
	"time"
)

type Device struct {
	DeviceID  string
	ExpiresAt string
	Blocked   bool
}

func GetDevice(deviceID string) (*Device, error) {
	row := DB.QueryRow(`
		SELECT device_id, expires_at, blocked
		FROM devices
		WHERE device_id = ?
	`, deviceID)

	var d Device
	var blocked int

	err := row.Scan(
		&d.DeviceID,
		&d.ExpiresAt,
		&blocked,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}

	if err != nil {
		return nil, err
	}

	d.Blocked = blocked != 0

	return &d, nil
}

func (d *Device) SubscriptionActive() bool {

	if d.Blocked {
		return false
	}

	if d.ExpiresAt == "" {
		return true
	}

	expireTime, err := time.Parse(time.RFC3339, d.ExpiresAt)
	if err != nil {
		return false
	}

	return time.Now().Before(expireTime)
}
