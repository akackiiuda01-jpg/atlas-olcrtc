package atlasauth

import (
	"fmt"
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

	device, err := database.GetDevice(deviceID)
	if err != nil {
		return "", err
	}

	if device == nil {

		log.Println("New device. Registering...")

		if err := database.RegisterDevice(deviceID); err != nil {
			return "", err
		}

		device, err = database.GetDevice(deviceID)
		if err != nil {
			return "", err
		}

		log.Println("Device registered")
	} else {
		log.Println("Device already registered")
	}

	if !device.SubscriptionActive() {
		log.Println("Subscription expired or device blocked")
		return "", fmt.Errorf("subscription inactive")
	}

	log.Printf("SessionID: %s", sessionID)
	log.Println("==============================")

	return sessionID, nil
}
