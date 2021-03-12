CIDFILE=/tmp/.docker.nsu

docker stop `cat $CIDFILE`
rm $CIDFILE