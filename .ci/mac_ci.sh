#!/bin/bash

# Usage:
#       ./mac_ci.sh {version}
# Example:
#       ./mac_ci.sh 2.2-beta.1

git clone -b emqx30_release https://github.com/emqx/emqx-rel
version=`cd emqx-rel && git describe --abbrev=0 --tags`
pkg=emqx-macosx-${version}.zip
echo "building $pkg..."
cd emqx-rel && make && cd _rel && zip -rq $pkg emqx
ssh -o StrictHostKeyChecking=no ubuntu@emqx-ci "mkdir -p /opt/emq_packages/free/${version}" 
scp -o StrictHostKeyChecking=no _rel/$pkg ubuntu@emqx-ci:/opt/emq_packages/free/${version}
