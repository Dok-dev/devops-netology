#!/bin/bash

a=1
b=2
c=a+b # с - будет присвоена строка 'a+b'
d=$a+$b # d - бует присвоена строка из начений 1'+'2
e=$(($a+$b)) # e - будет передан результат арифметической операции сложения значений переменных а и в, .т.е 3.

echo $c
echo $d
echo $e