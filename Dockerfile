ARG BASE_IMAGE_TAG=null
FROM golang:${BASE_IMAGE_TAG} AS builder

WORKDIR /src/
COPY . .

ARG GOOS=null
ARG GOARCH=null
ARG GOLDFLAGS=null

RUN go get -d -v
RUN GOOS=$GOOS GOARCH=$GOARCH GO111MODULE=on go build -ldflags "$GOLDFLAGS" -o /bin/workload-scheduler

# -----------------------------------------------

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /bin/workload-scheduler /bin/workload-scheduler
USER nonroot:nonroot
ENTRYPOINT ["/bin/workload-scheduler"]