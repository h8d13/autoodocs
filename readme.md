# barehands

> Assumes SSH access

Create a `bare` repo on the "server"

`git init --bare user.git`

Then `clone` it locally

`git clone user@<ip>:~/git-repos/user.git`

Add to `hooks`:

post-receive
```shell
#!/bin/bash
git --work-tree=/home/$USER/projects --git-dir=/home/$USER/Barehands/barehands.git checkout -f
```
