# syntax=docker/dockerfile:1

FROM ocaml/opam:ubuntu-24.10-ocaml-5.3@sha256:32bfaa6b06f5cc77c6129a271a9bda0e7909dfb381e9a87b5077ae9feef0684b AS tools
RUN sudo ln -f /usr/bin/opam-2.3 /usr/bin/opam
RUN opam init --reinit -ni
RUN opam install opam-0install
RUN git clone https://github.com/jonludlam/opamh
RUN cd opamh && opam install . --deps-only --with-test --with-doc
RUN cd opamh && opam exec -- dune build

FROM ocaml/opam:ubuntu-24.10-ocaml-5.3@sha256:32bfaa6b06f5cc77c6129a271a9bda0e7909dfb381e9a87b5077ae9feef0684b
RUN sudo ln -f /usr/bin/opam-2.3 /usr/bin/opam
RUN opam init --reinit -ni
COPY --from=tools /home/opam/.opam/*/bin/opam-0install /home/opam/opamh/_build/default/opamh.exe /usr/bin
# run a solve to initialise the cache
RUN opam-0install ocaml
