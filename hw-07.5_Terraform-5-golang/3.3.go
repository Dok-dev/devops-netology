package main

import (
	"fmt"
)

func printD3(value1 int, value2 int) {
	for ;value1 < value2; {

		if (value1 % 3) == 0 {
			fmt.Print(value1,", ")
			value1 = value1 + 2
		}
		value1++
	}
}

func main() {

	printD3(1,100)

}