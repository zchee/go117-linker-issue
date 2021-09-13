package main

import (
	"encoding/json"
	"os"
)

var dec *json.Decoder

func init() {
	dec = json.NewDecoder(os.Stdout)
}
