package main

import (
	"fmt"
	"os"
	"plugin"

	_ "encoding/json"
)

func main() {
	plugin.Open(fmt.Sprintf("plugin-%s.so", os.Args[1]))
}
