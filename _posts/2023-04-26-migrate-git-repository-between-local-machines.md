---
title: Migrate a Git Repository between Local Machines
tags: git, migration
---

Something you might encounter when migrating to a new machine:

* You want a full copy of a repository from your old machine, including branches.
* You don't want any development clutter like tmp files or log files.
* You don't want to include .env files or other sensitive files that are
  normally ignored by your `.gitignore` file.
* You don't want to just push and pull all of those branches on the official company origin and muck it up.

How can you do this? Just use git! You can make the old machine "_just another origin_"
and clone it like any other repository.

### 1. Enable Remote Login for the old machine

These steps assume you are on a Mac OS.

* Go to Settings > General > Sharing.
* Enable Remote Login.

### 2. Clone the Repository

Since you have enabled remote login, you can clone the repository using the old
machine as a remote, just like any other.

```
git clone username@My-MacBook.local:/Users/user/path/to/my_project/.git my_project
```

  * `username` is your username on the old machine.
  * `My-MacBook.local` is the network name for your old machine. You can find
    this in the sharing settings page, near computer name.
  * `/Users/user/path/to/my_project/.git` is the path to the .git directory of
    your project on the old machine.
  * `my_project` is the name of the folder to clone into on the new machine.

You should be prompted for the old machine's password. Git will clone the repo.
You should see the repository working tree and all of your branches.

```
cd my_project
git branch -a

remotes/origin/before-upgrade-rails
remotes/origin/blazer
remotes/origin/bug-check
remotes/origin/ci
remotes/origin/clock-adjust
...
```

### 3. Checkout your Branches

You have the project cloned and you should be able to see your branches, but
they are still remote branches and they're pointed to your old machine as their
remote tracking branch, which isn't ideal.

You want all of them to exist on your new machine, and eventually point to the
official company origin.

Check out each of the remote branches so we can have a copy locally:

```
git branch -a | grep remotes \
    | sed s/\ \ remotes\\/origin\\///g \
    | xargs -I{} git checkout '{}'
```

The above will check out each branch one by one, so they're made available
locally. You'll see each branch checked out with a message resembling:

```
Switched to a new branch 'before-upgrade-rails'
branch 'before-upgrade-rails' set up to track 'origin/before-upgrade-rails'.
```

Now each of those branches exists locally, on your new machine.

```
git branch

before-upgrade-rails
blazer
bug-check
ci
clock-adjust
...
```

### 4. Update origin to GitHub origin

Now that each branch exists locally, you can clean up and remove the origin
pointing to your old machine and add the real GitHub or company origin,
wherever that may be.

```
git remote rm origin
git remote add origin git@github.com:user/my_project.git
```

Additionally, if you do not want to specify the new upstream every time
 you revisit one of your branches, you can point them to the official origin all
at once:

```
git branch | xargs -I{} git checkout {} && git branch -u origin/{}
```

Now when you check out one of the branches it should already be pointed at your
actual origin repository.

```
git checkout blazer
git remote show origin
* remote origin
  Fetch URL: git@github.com:user/my_project.git
  Push  URL: git@github.com:user/my_project.git
  HEAD branch: main
```

Without this step you will just need to specify the upstream when you return to
one of the branches and try to push:

```
fatal: The current branch ci has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin ci
```

### 5. Turn off Remote Login

If you don't want to keep remote login available for your old machine,
remember to turn it off.

## Why not just copy and paste?

You _can_ simply copy and paste your project directory from old machine to new
machine.  That should work as well, but as noted earlier you'll be bringing
along the entire content of the directory.

That might be okay (or even desirable) for your situation.  Just keep in mind
all development files, log files, and any sensitive files will come over also.

Cloning the repo using the steps outlined in these notes will honor
everything in your `.gitignore` file. Copying the folder directly over to your
new machine won't.

## Conclusion

To summarize, if you need to move a Git repository from one local machine to
another, cloning the repository using the old machine as a remote is one way to
go. This allows you to easily move all branches and avoid bringing over any
unwanted files. Following the steps outlined in these notes will ensure that
everything in your `.gitignore` file is honored.

One caveat to note is that hooks won't come along in this process.
Keep that in mind when choosing your preferred method.
