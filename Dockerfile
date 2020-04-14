ARG GO_VERSION=1.14.1
ARG ALPINE_VERSION=3.11

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN apk add --no-cache build-base musl-dev git upx \
 && go get golang.org/x/tools/cmd/present \
 && go build -a -tags netgo -ldflags '-w -extldflags "-static"' golang.org/x/tools/cmd/present \
 && upx /go/bin/present

FROM alpine:${ALPINE_VERSION} AS presenter
COPY --from=builder /go/bin/present /usr/local/bin/present
WORKDIR /present
COPY --from=builder /go/src/golang.org/x/tools/cmd/present/static/ ./static/
COPY --from=builder /go/src/golang.org/x/tools/cmd/present/templates/ ./templates/
WORKDIR /tmp/css
COPY ./css/ ./
RUN find /present/static -type f -name '*.css' | xargs -rI{} sh -c 'cat /tmp/css/*.css >> {}' \
 && rm -rvf /tmp/css
WORKDIR /present/docroot
COPY ./docroot/ ./
COPY ./bin/presenter /usr/local/bin/
RUN ln -s /usr/local/bin/presenter /usr/local/bin/presenter.shared
CMD ["presenter"]
