# Git Migrate

## Prerequesites

1. Clone Git repository
2. Generate access token
3. Add SSH Key to Gitlab
4. Configure script:

```bash

GITHUB_TOKEN="" # Add your github access token (Make sure you have necessary permissions)

GITHUB_USERNAME="" # Add your github name

FROM="http://git.bbcag.ch/inf-bl/zh/2023" # Change From where to get repositories if you like to

GITLAB_SSH="ssh://git@git.bbcag.ch:2222/inf-bl/zh/2023" # SSH url

TO="https://github.com/${GITHUB_USERNAME}" # Change Destination if you like to
REPOS=(
    "/a"
    "/b"
) # Add all repository paths, in the example above the url would be: http://git.bbcag.ch/inf-bl/zh/2023/a
```
