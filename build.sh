#!/bin/bash

set -o pipefail

for pkg in $(opam list --all --short) ; do
  if [ ! -f good/$pkg ] && [ ! -f bad/$pkg ] ; then
    echo Building $pkg
    docker build --build-arg PKG=$pkg --progress=plain -t test docker 2>&1 | tee $pkg
    if [ $? -eq 0 ] ; then
      docker rmi test
      mv $pkg good
    else
      mv $pkg bad
    fi
  fi
done
