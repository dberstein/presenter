ARG ALPINE_VERSION=3.11
ARG GO_VERSION=1.14.1

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder
RUN apk add --no-cache git musl-dev \
 && go get -v golang.org/x/tools/cmd/present

FROM alpine:${ALPINE_VERSION} AS presenter
COPY --from=builder /go/ /go/
WORKDIR /docroot
COPY ./docroot/ ./
COPY ./bin/presenter /usr/local/bin/presenter
RUN ln -s /usr/local/bin/presenter /usr/local/bin/presenter.shared
CMD ["presenter"]
