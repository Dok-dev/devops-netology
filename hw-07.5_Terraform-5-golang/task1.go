package main

import "fmt"

func main() {
	fmt.Print("Enter the value in meters: ")
	var input float64
	fmt.Scanf("%f", &input)

	output := input / 0.3048

	fmt.Println("This value is in feet: ", output)
}