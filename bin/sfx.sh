#!/bin/sh

: "${PRESENTER_CMD:=docker}"
: "${PRESENTER_HOST:=127.0.0.1}"
: "${PRESENTER_PORT:=8080}"
: "${PRESENTER_OPENER:=xdg-open}"

echo_bold() {
    echo $(tput bold)$@$(tput sgr0)
}

offset() {
    awk '/^#__TARFILE_FOLLOWS__/ {print NR+1; exit 0;}' $0
}

container_run() {
    $PRESENTER_CMD run --rm -d -p $PRESENTER_PORT:80 $1
}

image_error() {
    $PRESENTER_CMD rmi -f $1
    echo >&2 Try: $(echo_bold "env PRESENTER_CMD=$PRESENTER_CMD PRESENTER_PORT=$(echo $PRESENTER_PORT+1 | bc) sh $0") \
    && exit 1;
}

container_cleanup() {
    echo -e "\nCommand to remove imported image:\n$(tput bold)$PRESENTER_CMD rmi -f $1$(tput sgr0)\n"
}

container_opener() {
    $PRESENTER_OPENER http://${PRESENTER_HOST}:${PRESENTER_PORT}
}

[ -z $(command -v $PRESENTER_OPENER) ] && PRESENTER_OPENER=open
[ -z $(command -v "$PRESENTER_CMD") ] && { echo_bold "Command not found:" $PRESENTER_CMD && exit 1; }
IMAGE="$(tail -n +$(offset) $0 | $PRESENTER_CMD import --change "CMD presenter.shared" --message "created by https://github.com/dberstein/presenter at $(date)" -)" \
&& [ -n $IMAGE ] && CONTAINER=$(container_run $IMAGE || image_error $IMAGE) \
&& [ -n $CONTAINER ] && container_cleanup $IMAGE && container_opener
exit 0
# NOTE: Don't place any newline characters after the last line below
#__TARFILE_FOLLOWS__
