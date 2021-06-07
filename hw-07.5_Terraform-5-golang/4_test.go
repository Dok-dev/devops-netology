package main

import "testing"

func TestPrint_d3(t *testing.T) {

	testRange := PrintD3(-110,110)

	for _, n := range testRange {
		r := n % 3
		if r > 0 {
			t.Error("There is an indivisible by 3 number - ", n)
		}
	}
	fmt.Print(PrintD3(1,100))
}
