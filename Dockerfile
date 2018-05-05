FROM debian:stretch

RUN apt-get update && \
    apt-get install -y git wget unzip && \
    wget -qO- https://get.haskellstack.org/ | sh

COPY site /site-for-prebuild

# I really hope dependencies are cached systemwide
RUN cd /site-for-prebuild && \
    stack --no-terminal --install-ghc setup && \
    stack build --no-terminal --only-dependencies