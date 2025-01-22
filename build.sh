#!/bin/bash

set -o pipefail

mkdir -p {good,bad,unavailable,download-cache,var-cache-apt,var-lib-apt,opam-cache}
sudo chown 1000:1000 {opam-cache,download-cache}

docker build --progress=plain -t base docker

for pkg in $(opam list --all --short) ; do
  if [ ! -f good/$pkg ] && [ ! -f bad/$pkg ] && [ ! -f unavailable/$pkg ] ; then
    echo Testing $pkg
    docker run --rm -v ./opam-cache:/opam-cache -v ./download-cache:/home/opam/.opam/download-cache -v ./var-cache-apt:/var/cache/apt -v ./var-lib-apt:/var/lib/apt -v ./script.sh:/home/opam/script.sh base ./script.sh $pkg 2>&1 | tee $pkg
    case $? in
      0) mv $pkg good ;;
      201) mv $pkg unavailable ;;
      *) mv $pkg bad ;;
    esac
  fi
done
