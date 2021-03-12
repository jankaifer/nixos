CIDFILE=/tmp/.docker.nsu

docker exec -it -u pearman `cat $CIDFILE` $@