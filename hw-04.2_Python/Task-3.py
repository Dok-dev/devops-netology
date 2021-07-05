import os
import sys
import git

try:
 path = sys.argv[1]
except Exception:
  print('Input path to git repository')
  path = input()

if os.path.exists(path):
    try:
        git.Repo(path).git_dir
        bash_commands = ["cd " + path, "git status"]
        try:
           result_os = os.popen(' && '.join(bash_commands)).read()
        except git.exc.GitError as e:
           print(e)
           exit(1)
        for result in result_os.split('\n'):
            if result.find('modified') != -1:
               prepare_result = os.path.join(path, (result.replace('\tmodified:   ', '')))
               print(prepare_result)
    except git.exc.InvalidGitRepositoryError:
        print(f'Git repository not found in {path} !')
else:
    print('Path not exists!')
