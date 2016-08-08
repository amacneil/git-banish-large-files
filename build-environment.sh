#!/bin/bash -eux
# Create a pre-receive hook environment for use with GitHub Enterprise
# Currently required because GHE 2.7.0 does not include awk

name=alpine-environment
rm -f $name.tar.gz
docker rm -f $name || true
docker build -t $name .
docker create --name $name $name /bin/true
docker export $name | gzip > $name.tar.gz
ls -lh $name.tar.gz
