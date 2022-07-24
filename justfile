set dotenv-load

BINDIR    := justfile_directory() + "/bin"
BINNAME   := "workload-scheduler"
BUILDTIME := `date "+%Y-%m-%dT%H:%M:%S"`

# git
LASTTAG     := `git tag --sort=committerdate | tail -1`
GITSHORTSHA := `git rev-parse --short HEAD`

# docker option
DFULLTAG  := LASTTAG
DMINORTAG := `git tag --sort=committerdate | tail -1 | cut -d '.' -f 1,2`
DMAGORTAG := `git tag --sort=committerdate | tail -1 | cut -d '.' -f 1`

DFNAME       := "Dockerfile"
DRPREFIXNAME := "docker.io/aryazanov"
DRWSNAME     := DRPREFIXNAME + "/workload-scheduler"
DRCICNAME    := DRPREFIXNAME + "/workload-scheduler-ci-container"

# go option
PKG        := "."
TESTS      := "."
TESTFLAGS  := ""
TAGS       := ""

GOLDFLAGS := "-w -s"
GOFLAGS   := "-ldflags '" + GOLDFLAGS + "'"

GOOS   := "linux"
GOARCH := "amd64"

# This list of available targets.
default:
	@just --list

# Build and push CI container.
build-push-ci-container user password:
	@devcontainer build --no-cache --image-name {{DRCICNAME}}:{{DFULLTAG}}
	@docker tag {{DRCICNAME}}:{{DFULLTAG}} {{DRCICNAME}}:{{DMINORTAG}}
	@docker tag {{DRCICNAME}}:{{DFULLTAG}} {{DRCICNAME}}:{{DMAGORTAG}}
	@docker login -u {{user}} -p {{password}}
	@docker image push --all-tags {{DRCICNAME}}

# Build source code.
build:
	@go build {{GOFLAGS}} -tags '{{TAGS}}' -o {{BINDIR}}/{{BINNAME}} .

# Run unit tests.
test:
	@go test {{GOFLAGS}} -run {{TESTS}} {{PKG}} {{TESTFLAGS}}

# Deploying a service and its dependencies on a Minikube cluster.
minikube-deploy:
	@skaffold dev --port-forward --no-prune=false --cache-artifacts=false

# Running integration tests inside a Minikube cluster.
minikube-test:
	@echo "2"
#	@skaffold dev ...

# Removing a service and its dependencies from a Minikube cluster.
minikube-delete:
	@skaffold delete

# Build and push application docker image.
build-push-image:
	@docker build \
		--build-arg BASE_IMAGE_TAG=$GOLANG_BASE_IMAGE_TAG \
		--build-arg GOOS={{GOOS}} \
		--build-arg GOARCH={{GOARCH}} \
		--build-arg GOLDFLAGS={{GOLDFLAGS}} \
		-t {{DRWSNAME}}:{{DFULLTAG}} \
		-f ./{{DFNAME}} .
	@docker push {{DRWSNAME}}:{{DFULLTAG}}