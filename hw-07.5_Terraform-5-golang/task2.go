package main
 
 import (
 	"fmt"
 )
 
 var x = []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17}
 
 func Min(values []int) int {
 	min_value := values[0]
 	for _, n := range values {
 		if n < min_value {
 			min_value = n
 		}
 	}
 	return min_value
 }
 
 func main() {
 
 	output := Min(x)
 
 	fmt.Println("Minimum value of array is: ", output)
 }