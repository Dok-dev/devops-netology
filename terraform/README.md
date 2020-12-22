Исключит все папки .terraform и вложенные в них файлы
  * `**/.terraform/*'

Исключит все файлы с расширением .tfstate и включающие в свое имя .tfstate.
  * `*.tfstate'
  * `*.tfstate.*'

Исключит файл crash.log
  * `crash.log'


Исключит все файлы с расширением .tfvars
  * `*.tfvars'

Исключит файлы override.tf, override.tf.json
и исключит все файлы начинающиеся с *_override.tf и *_override.tf.json
  * `override.tf'
  * `override.tf.json'
  * `*_override.tf'
  * `*_override.tf.json'

Отслеживать файл example_override.tf даже если он попадает под исключение
  * `!example_override.tf'

Исключит все файлы включающие в свое имя tfplan
  * `example: *tfplan*'

Исключит файлы .terraformrc и terraform.rc
  * `.terraformrc'
  * `terraform.rc'
