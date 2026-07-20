package atlasauth

import (
	"log"

	"github.com/google/uuid"

	"github.com/openlibrecommunity/olcrtc/internal/database"
)

func AtlasAuth(deviceID string, claims map[string]any) (string, error) {
	sessionID := uuid.NewString()

	log.Println("==============================")
	log.Println(" AtlasAuth")
	log.Println("==============================")
	log.Printf("DeviceID : %s", deviceID)
	log.Printf("Claims   : %#v", claims)

	exists, err := database.DeviceExists(deviceID)
	if err != nil {
		return "", err
	}

	if !exists {
		log.Println("New device. Registering...")

		if err := database.RegisterDevice(deviceID); err != nil {
			return "", err
		}

		log.Println("Device registered")
	} else {
		log.Println("Device already registered")
	}

	log.Printf("SessionID: %s", sessionID)
	log.Println("==============================")

	return sessionID, nil
}
