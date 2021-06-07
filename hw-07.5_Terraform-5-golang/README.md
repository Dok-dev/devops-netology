# Домашнее задание «7.5. Основы golang»

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

---

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

---

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:

>**Ответ:**    
>```go
>package main
>
>import "fmt"
>
>func main() {
>	fmt.Print("Enter the value in meters: ")
>	var input float64
>	fmt.Scanf("%f", &input)
>
>	output := input / 0.3048
>
>	fmt.Println("This value is in feet: ", output)
>}
>```

2. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
>**Ответ:**    
```go
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
```
   
3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

>**Ответ:**    
```go
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
```
---

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

>**Ответ:**   
>Немного преобразуем код предыдущего зания, что бы получать массив для проверки. 
```go
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
```

Теперь сделаем тест для проверки работы функции PrintD3:
```go
package main

import "testing"

func TestPrintD3(t *testing.T) {

	testRange := PrintD3(-110,110)

	for _, n := range testRange {
		r := n % 3
		if r > 0 {
			t.Error("There is an indivisible by 3 number - ", n)
		}
	}
}
```