ARG BUILD_IMAGE_TAG=latest
FROM golang:${BUILD_IMAGE_TAG} AS builder

WORKDIR /src/
COPY . .

ARG GOOS=linux
ARG GOARCH=amd64
ARG LDFLAGS="-w -s"
RUN go get -d -v
RUN GOOS=$GOOS GOARCH=$GOARCH GO111MODULE=on go build -ldflags "$LDFLAGS" -o /bin/workload-scheduler

# -----------------------------------------------

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /bin/workload-scheduler /bin/workload-scheduler
USER nonroot:nonroot
ENTRYPOINT ["/bin/workload-scheduler"]