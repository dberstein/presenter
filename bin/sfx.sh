#!/bin/sh

: "${PRESENTER_CMD_DOCKER:=docker}"
: "${PRESENTER_PORT:=8080}"
: "${OPENER:=xdg-open}"

[ -z $(command -v "$PRESENTER_CMD_DOCKER") ] && { echo $(tput bold)Command not found:$(tput sgr0) $PRESENTER_CMD_DOCKER; exit 1; }
[ -z $(command -v $OPENER) ] && OPENER=open

offset() {
    awk '/^__PAYLOAD_FOLLOWS_LINE__:/ {print NR+1; exit 0;}' $0
}

container_run() {
    $PRESENTER_CMD_DOCKER run --rm -d -p $PRESENTER_PORT:80 $1
}

image_error() {
    $PRESENTER_CMD_DOCKER rmi -f $1
    echo >&2 "Try: $(tput bold)env PRESENTER_CMD_DOCKER=$PRESENTER_CMD_DOCKER PRESENTER_PORT=$(echo $PRESENTER_PORT+1 | bc) sh $0$(tput sgr0)"; exit 1;
}

container_cleanup() {
    echo -e "\nCommand to remove imported image:\n$(tput bold)$PRESENTER_CMD_DOCKER rmi -f $1$(tput sgr0)\n"
}

container_opener() {
    $OPENER http://127.0.0.1:${PRESENTER_PORT}
}

IMAGE=$(tail -n +$(offset) $0 | $PRESENTER_CMD_DOCKER import --change "CMD presenter" --message "created by https://github.com/dberstein/presenter at $(date)" -) \
&& [ -n $IMAGE ] && CONTAINER=$(container_run $IMAGE || image_error $IMAGE) \
&& [ -n $CONTAINER ] && container_cleanup $IMAGE && container_opener

exit 0
__PAYLOAD_FOLLOWS_LINE__:
