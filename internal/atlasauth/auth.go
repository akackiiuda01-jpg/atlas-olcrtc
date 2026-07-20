package atlasauth

import (
	"log"

	"github.com/google/uuid"
)

func AtlasAuth(deviceID string, claims map[string]any) (string, error) {
	sessionID := uuid.NewString()

	log.Println("====================================")
	log.Println(" AtlasAuth")
	log.Println("====================================")
	log.Printf("DeviceID : %s", deviceID)
	log.Printf("Claims   : %#v", claims)
	log.Printf("SessionID: %s", sessionID)
	log.Println("====================================")

	return sessionID, nil
}
