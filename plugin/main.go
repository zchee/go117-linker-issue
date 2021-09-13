// package main
//
// import (
// 	"encoding/json"
// 	"os"
// )
//
// var Dec *json.Decoder
//
// func init() {
// 	Dec = json.NewDecoder(os.Stdout)
// }

package main

import (
	"os"

	"google.golang.org/grpc"
)

var (
	Conn *grpc.ClientConn
	err  error
)

func init() {
	Conn, err = grpc.Dial(os.Getenv("ENDPOINT"), grpc.WithInsecure())
}
