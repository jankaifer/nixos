FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -qqy x11-apps firefox sudo
USER pearman
WORKDIR /home/pearman
ENV DISPLAY :0
CMD bash 