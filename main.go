package main

import "fmt"

func main() {
	charsPrinted, err := fmt.Println("Hello user!")
	fmt.Println("Printed:", charsPrinted)
	if err == nil {
		fmt.Println("Error:", err)
	}
}
