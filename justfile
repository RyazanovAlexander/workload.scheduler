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

# Build local content to public directory.
build:
    @go build {{GOFLAGS}} -tags '{{TAGS}}' -o {{BINDIR}}/{{BINNAME}} .

# Running project unit tests.
test:
	@go test {{GOFLAGS}} -run {{TESTS}} {{PKG}} {{TESTFLAGS}}

# # 1.
# devcontainer:
# 	@echo "1"

# # 1.
# run:
# 	@echo "1"

# # 1.
# publish:
# 	@echo "1"

# # 2.
# local deploy:
# 	@echo "2"
# #	@skaffold dev --port-forward --no-prune=false --cache-artifacts=false

# # 3.
# local delete:
# 	@echo "3"
# #	@skaffold delete

