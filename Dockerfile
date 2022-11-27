ARG BASE_IMAGE_TAG=null
ARG GOOS=null
ARG GOARCH=null
ARG GOLDFLAGS=null

FROM golang:${BASE_IMAGE_TAG} AS builder

WORKDIR /src/
COPY . .

RUN go get -d -v
RUN GOOS=$GOOS GOARCH=$GOARCH GO111MODULE=on go build -ldflags "$GOLDFLAGS" -o /workload-scheduler

# -----------------------------------------------

FROM ubuntu:22.10
COPY --from=builder /workload-scheduler /workload-scheduler
ENTRYPOINT ["/workload-scheduler"]