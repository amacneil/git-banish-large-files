# git-banish-large-files

See the code: [pre-receive.sh](/pre-receive.sh)

When hosting a large git repository, it's critical to prevent large files being accidentally committed. This pre-receive hook will check all objects pushed to make sure they are below a defined threshold.

There is existing prior art for this online, but all scripts I came across had limitations:

* Some scripts only diff the previous and new commit, which means they will not catch instances where a developer committed a large file, then deleted it in a later commit. We especially want to avoid unused large files being added to history.
* Some scripts were very slow. GitHub Enterprise has a 5 second timeout for pre-receive hooks, so we can't afford to spend minutes looping through every commit and testing each object individually.

This approach uses `git rev-list --objects` to find every object between a series of commits, then it efficiently pipes the objects to `git cat-file` to fetch the object type and size, followed by a final pipe to `awk` to find and print large files. Hat tip to GitHub Enterprise support for the pointers to these particular git commands.
