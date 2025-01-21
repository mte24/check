# syntax=docker/dockerfile:1

FROM ocaml/opam:ubuntu-24.10-ocaml-5.3@sha256:32bfaa6b06f5cc77c6129a271a9bda0e7909dfb381e9a87b5077ae9feef0684b AS tools
RUN sudo ln -f /usr/bin/opam-2.3 /usr/bin/opam
RUN opam init --reinit -ni
RUN opam install opam-0install
RUN git clone https://github.com/jonludlam/opamh
RUN cd opamh && opam install . --deps-only --with-test --with-doc
RUN cd opamh && opam exec -- dune build

FROM ocaml/opam:ubuntu-24.10-ocaml-5.3@sha256:32bfaa6b06f5cc77c6129a271a9bda0e7909dfb381e9a87b5077ae9feef0684b
RUN sudo rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | sudo tee /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    sudo apt update
RUN sudo ln -f /usr/bin/opam-2.3 /usr/bin/opam
RUN opam init --reinit -ni
COPY --from=tools /home/opam/.opam/*/bin/opam-0install /home/opam/opamh/_build/default/opamh.exe /usr/bin
ARG PKG
RUN set -o pipefail && opam-0install -t ${PKG} 'ocaml=5.3.0' | awk -v pkg=${PKG} '{ for (i = 1; i <= NF; i++) { split($i, s, "."); if (s[1] != pkg) { print $i } } }' > deps
RUN --mount=type=cache,target=/opam-cache,uid=1000,gid=1000 \
    for dep in $(cat deps) ; do if [ -f "/opam-cache/$dep" ] && [ ! -d "/home/opam/.opam/5.3/.opam-switch/packages/$dep" ] ; then tar -xf /opam-cache/$dep -C / ; fi ; done
RUN opamh.exe make-state --output=/home/opam/.opam/5.3/.opam-switch/switch-state
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    opam install --depext-only $(cat deps)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/home/opam/.opam/download-cache,uid=1000,gid=1000 \
    opam install $(cat deps)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/home/opam/.opam/download-cache,uid=1000,gid=1000 \
    opam install ${PKG}
RUN --mount=type=cache,target=/opam-cache,uid=1000,gid=1000 \
    opam list --short --columns=name,installed-version | awk '{ output="/opam-cache/" $1 "." $2; if (system("test -f " output)) system ("opamh.exe save --output " output " " $1) }'
