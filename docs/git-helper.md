# C1: How to check the latest commit of "build" image
```
cd moby/build
git log -n1 --format=%h
docker pull utas-change-registry.dynamic.nsn-net.net:5000/opentas/build:BUILD_xxxx
here xxxx is the output of "git log -n1 format=%h"
```
# C2: How to find the reason of merge failure
```
git log --merge --left-right -p [failurefile]
```
# C3: How to find what file merge failure
```
git log --merge --left-right -p [failurefile]
```
# C4: How to recover current directory and index to HEAD(no change)
```
git reset --hard HEAD
```
# C5: How to undo merge when it already finishes
```
git reset --hard ORIG_HEAD
```
# C6: How to unstage file
```
git reset HEAD file
```
# C7: How to uncommit file
```
git reset --mixed HEAD^
```
# C8: How to submit one commit in current branch which has been submitted to another branch
```
git cherry-pick dev~2
```
# C9: How to change the latest commit
```
git commit --amend
```
# C10: How to do forwarding porting
```
git rebase master topic # rebase topic branch onto the latest commit of master branch
```
# C11: How to change commit order or merge commit
```
git rebase -i master~3
```
# C12: How to find GIT command history
```
git reflog show
```
# C13: How to differ git fetch and git pull
```
In the simplest terms, git pull does a git fetch followed by a git merge.
You can do a git fetch at any time to update your remote-tracking branches under refs/remotes/<remote>/.
This operation never changes any of your own local branches under refs/heads, and is safe to do without changing your working copy. I have even heard of people running git fetch periodically in a cron job in the background (although I wouldn't recommend doing this).
A git pull is what you would do to bring a local branch up-to-date with its remote version, while also updating your other remote-tracking branches.
```
# C14: How to fix username/passwd request when git push
```
A common mistake is cloning using the default (HTTPS) instead of SSH. You can correct this by going to your repository, clicking "Clone or download", then clicking the "Use SSH" button above the URL field and updating the URL of your origin remote like this:

git remote set-url origin git@github.com:username/repo.git

This is documented at GitHub: Switching remote URLs from HTTPS to SSH.

Or update the following command to enable credential caching:

$ git config credential.helper store
$ git push https://github.com/owner/repo.git

Username for 'https://github.com': <USERNAME>
Password for 'https://USERNAME@github.com': <PASSWORD>

You should also specify caching expire,

git config --global credential.helper 'cache --timeout 7200'

After enabling credential caching, it will be cached for 7200 seconds (2 hour).
```
