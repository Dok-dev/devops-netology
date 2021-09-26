### Задача 3 "API Gateway"


#### Проверка
получаем токен:
```console
$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
```
запрос без токена:
```console
$ curl -X POST -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
Warning: Couldn't read data from file "1.jpg", this makes an empty POST.
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx/1.21.3</center>
</body>
</html>
```
запрос с токеном:
```console
$ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
{"filename":"b3c5c420-27a7-404f-a85b-4ec3bb694c01.jpg"}
```
загружаем картинку назад:
```console
$ curl http://localhost/images/b3c5c420-27a7-404f-a85b-4ec3bb694c01.jpg 2.jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12117  100 12117    0     0   591k      0 --:--:-- --:--:-- --:--:--  622k
$ ls -lha *.jpg
-rw-rw-r-- 1 vagrant vagrant 12K Feb  3  2020 1.jpg
-rw-rw-r-- 1 vagrant vagrant 12K Sep 26 14:03 2.jpg
```
