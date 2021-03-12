XSOCK=/tmp/.X11-unix                                              
XAUTH=/tmp/.docker.xauth
CIDFILE=/tmp/.docker.nsu

xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

./stop_nsu.sh

echo Building container ...
docker build -t nsu - < ./Dockerfile

echo Starting container ...
docker run -t \
  -v "$XSOCK:$XSOCK" \
  -v "$XAUTH:$XAUTH" \
  -v /home:/home \
  -e "XAUTHORITY=$XAUTH" \
  --cidfile=$CIDFILE \
  nsu &