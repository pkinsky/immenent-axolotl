FROM debian:stretch

RUN apt-get update && \
    apt-get install -y git wget unzip && \
    wget -qO- https://get.haskellstack.org/ | sh

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US

COPY site /site-for-prebuild

RUN cd /site-for-prebuild && \
    stack --no-terminal --install-ghc setup && \
    stack build --no-terminal --only-dependencies

#hacky-ass UTF-8 support cargo culting follows
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
# just run this twice because it errors the first time hashtag YOLO, ugh
RUN echo "Europe/Oslo" > /etc/timezone && \
      dpkg-reconfigure -f noninteractive tzdata && \
      sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
      sed -i -e 's/# nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/' /etc/locale.gen && \
      echo 'LANG="nb_NO.UTF-8"'>/etc/default/locale && \
      dpkg-reconfigure --frontend=noninteractive locales && \
      update-locale LANG=nb_NO.UTF-8
RUN echo "Europe/Oslo" > /etc/timezone && \
      dpkg-reconfigure -f noninteractive tzdata && \
      sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
      sed -i -e 's/# nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/' /etc/locale.gen && \
      echo 'LANG="nb_NO.UTF-8"'>/etc/default/locale && \
      dpkg-reconfigure --frontend=noninteractive locales && \
      update-locale LANG=nb_NO.UTF-8