#!/bin/bash

set -o pipefail

opam-0install -t $1 'ocaml=5.3.0' | awk -v pkg=$1 '{ for (i = 1; i <= NF; i++) { split($i, s, "."); if (s[1] != pkg) { printf "%s ", $i } } }' > deps
if [ $? -ne 0 ] ; then
  exit 201
fi

# awk '{ for (i = 1; i <= NF; i++) { split($i, s, "."); system("opam pin add " s[1] " --kind=version " s[2] "." s[3] "." s[4] " --no-action") } }'  deps

export OPAMPREPRO=false

for dep in $(<deps) ; do if [ -f /opam-cache/$dep ] && [ ! -d /home/opam/.opam/5.3/.opam-switch/packages/$dep ] ; then tar -xf /opam-cache/$dep -C / ; fi ; done
opamh.exe make-state --output=/home/opam/.opam/5.3/.opam-switch/switch-state
awk '{ for (i = 1; i <= NF; i++) { if (system("test -d /home/opam/.opam/5.3/.opam-switch/packages/" $i)) { printf "%s ", $i } } }' deps > new-deps
awk '{ for (i = 1; i <= NF; i++) { if (! system("test -d /home/opam/.opam/5.3/.opam-switch/packages/" $i)) { printf "%s ", $i } } }' deps > existing-deps
if [ -s existing-deps ] ; then opam install --depext-only $(<existing-deps) ; fi
if [ -s new-deps ] ; then opam install $(<new-deps) ; fi
opam install $1
rc=$?
opam list --short --columns=name,installed-version | awk '{ output="/opam-cache/" $1 "." $2; if (system("test -f " output)) system ("opamh.exe save --output " output " " $1) }'
exit $rc
