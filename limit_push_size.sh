#!/bin/bash -eu
set -o pipefail

nullsha="0000000000000000000000000000000000000000"

# Push size limit is meant to be configured through 'hooks.pushsizelimit' setting
maxsize=$(git config hooks.pushsizelimit)

# If we haven't configured a push size limit, use default value of about 100M
if [ -z "$maxsize" ]; then
    maxsize=100
fi

maxbytes=$(( $maxsize * 1024 * 1024 ))
status=0

# Read stdin for ref information
while read oldref newref refname; do
    # Skip branch deletions
    if [ "$newref" = "$nullsha" ]; then
        continue
    fi
    
    # Set oldref to HEAD if this is branch creation
    if [ "$oldref" = "$nullsha" ]; then
        oldref="HEAD"
    fi
    
    #sum of size of all objects
    sizeofpush=$(git rev-list --objects ${oldref}..${newref} | \
        git cat-file --batch-check='%(objectname) %(objecttype) %(objectsize) %(rest)' | \
    awk 'BEGIN{sum=0}{sum=sum+$3}END{print sum}');

    # Display error header
    if [ "$sizeofpush" -ge "$maxbytes" ] && [ "$status" -eq "0" ]; then
        status=1
        
        echo ""
        echo "-------------------------------------------------------------------------"
        echo "Your push was rejected because it is larger than $maxsize MB."
        echo "Please discuss with the infra team the best place to store these files."
        echo "You might want to consider using https://git-lfs.github.com/ instead."
        echo "-------------------------------------------------------------------------"
    fi
    
done

if [ "$status" -ne "0" ]; then echo; fi
exit $status
