CIDFILE=/tmp/.docker.nsu

docker exec -it -u 1000:100 `cat $CIDFILE` $@