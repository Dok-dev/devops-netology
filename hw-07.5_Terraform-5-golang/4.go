package main

import (
	"fmt"
)

func PrintD3(value1 int, value2 int) []int {
	var nums []int
	for ;value1 < value2; {
		if (value1 % 3) == 0 {
			nums = append(nums, value1)
			value1 = value1 + 2
		}
		value1++
	}
	return nums
}

func main() {

	fmt.Print(PrintD3(1,100))

}