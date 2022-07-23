set dotenv-load

BINDIR    := justfile_directory() + "/bin"
BINNAME   := "workload-scheduler"
BUILDTIME := `date "+%Y-%m-%dT%H:%M:%S"`

# git
LASTTAG     := `git tag --sort=committerdate | tail -1`
GITSHORTSHA := `git rev-parse --short HEAD`

# docker option
# DTAG   ?= $(LASTTAG)
# DFNAME ?= Dockerfile
# DRNAME ?= docker.io/aryazanov/workload-scheduler

# go option
PKG        := "."
TESTS      := "."
TESTFLAGS  := ""
TAGS       := ""

GOLDFLAGS := "-w -s"
GOFLAGS   := "-ldflags '" + GOLDFLAGS + "'"

# GOOS   := linux
# GOARCH := amd64

# This list of available targets.
default:
    @just --list

# Build source code.
build:
    @go build {{GOFLAGS}} -tags '{{TAGS}}' -o {{BINDIR}}/{{BINNAME}} .

# Run unit tests.
test:
	@go test {{GOFLAGS}} -run {{TESTS}} {{PKG}} {{TESTFLAGS}}

# Deploying a service and its dependencies on a Minikube cluster.
minikube-deploy:
	@echo "1"
#	@skaffold dev --port-forward --no-prune=false --cache-artifacts=false

# Running integration tests inside a Minikube cluster.
minikube-test:
	@echo "2"
#	@skaffold dev ...

# Removing a service and its dependencies from a Minikube cluster.
minikube-delete:
	@echo "3"
#	@skaffold delete

# # 1.
# devcontainer:
# 	@echo "1"

# # 1.
# publish:
# 	@echo "1"

