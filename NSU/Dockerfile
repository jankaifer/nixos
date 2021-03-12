FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -qqy x11-apps firefox sudo
RUN useradd -s /bin/bash pearman -u 1000 -g 100 -G sudo
WORKDIR /home/pearman
ENV DISPLAY :0
CMD bash 