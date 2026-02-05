# barehands

> Assumes SSH access
> Assumes you `mkdir`

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

You now should alread have a push / sync setup where you can see files update live after push.
