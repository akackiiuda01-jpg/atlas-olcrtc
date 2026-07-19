package atlasauth

import (
	"log"

	"github.com/google/uuid"
)

func AtlasAuth(deviceID string, claims map[string]any) (string, error) {
	log.Printf("[AtlasAuth] DeviceID=%s Claims=%v", deviceID, claims)

	return uuid.NewString(), nil
}
