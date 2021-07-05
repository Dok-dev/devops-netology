import os
import git

path = os.path.abspath(os.curdir)

bash_commands = ["cd " + path, "git status"]
try:
   result_os = os.popen(' && '.join(bash_commands)).read()
except git.GitError as e:
   print(e)
   exit(1)
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = os.path.join(path, (result.replace('\tmodified:   ', '')))
        print(prepare_result)

