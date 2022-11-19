set dotenv-load

BINDIR    := justfile_directory() + "/bin"
BINNAME   := "workload-scheduler"
BUILDTIME := `date "+%Y-%m-%dT%H:%M:%S"`
TMPDIR    := ".tmp"

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
DRDEVCNAME   := DRPREFIXNAME + "/workload-scheduler-dev-container"

# go option
PKG        := "."
TESTS      := "."
TESTFLAGS  := ""
TAGS       := ""

GOLDFLAGS := "-w -s"
GOFLAGS   := "-ldflags '" + GOLDFLAGS + "'"

GOOS   := "linux"
GOARCH := "amd64"

# cache
CACHE_DIR := ".devcontainer/.cache"
DEPENDENCIES_HELM := ".deploy/charts"

# skaffold
SKAFFOLD_PROFILE := "dependencies"

# This list of available targets.
default:
	@just --list

#	@minikube start --driver=podman --container-runtime=containerd
#   https://github.com/kubernetes/minikube/issues/9792
# Dev container initialization.
init:
	#!/bin/bash
	minikube start --force --driver=docker --cpus $MINIKUBE_CPU --memory $MINIKUBE_RAM
	mkdir -p {{CACHE_DIR}}
	if [ -z "$(ls -A {{CACHE_DIR}})" ]; then exit 0; fi
	for filename in {{CACHE_DIR}}/*; do docker load --input $filename; echo "Loaded $filename\n"; done
	rm -rf {{CACHE_DIR}}
	just minikube-run

# Build and push Dev container.
build-push-dev-container user password: _create_cache
	@devcontainer build --no-cache --image-name {{DRDEVCNAME}}:{{DFULLTAG}}
	@docker tag {{DRDEVCNAME}}:{{DFULLTAG}} {{DRDEVCNAME}}:{{DMINORTAG}}
	@docker tag {{DRDEVCNAME}}:{{DFULLTAG}} {{DRDEVCNAME}}:{{DMAGORTAG}}
	@docker login -u {{user}} -p {{password}}
	@docker image push --all-tags {{DRDEVCNAME}}
	rm -rf {{CACHE_DIR}}

# Creates a cache for used in the container.
_create_cache:
	#!/bin/bash
	rm -rf {{CACHE_DIR}} && mkdir {{CACHE_DIR}}
	images="$(helm template {{DEPENDENCIES_HELM}} | yq '..|.image? | select(.)' | grep -P -i '.*\/.*:.*')"
	for image in $images; do
		diname=`echo $image | md5sum | cut -f1 -d" "`;
		docker pull $image;
		docker save --output {{CACHE_DIR}}/$diname $image;
	done

# Build source code.
build:
	@go build {{GOFLAGS}} -tags '{{TAGS}}' -o {{BINDIR}}/{{BINNAME}} .

# Run unit tests.
test:
	@go test {{GOFLAGS}} -run {{TESTS}} {{PKG}} {{TESTFLAGS}}

# Deploying a service and its dependencies on a Minikube cluster in dev mode.
minikube-deploy:
	@skaffold dev --port-forward --no-prune=false --cache-artifacts=false --profile={{SKAFFOLD_PROFILE}}

# Deploying a service and its dependencies on a Minikube cluster in run mode.
minikube-run:
	@skaffold run --port-forward --no-prune=false --cache-artifacts=false --profile={{SKAFFOLD_PROFILE}}

# Running tests inside a Minikube cluster.
minikube-test:
	helm test workloadscheduler --namespace scheduler

# Removing a service and its dependencies from a Minikube cluster.
minikube-delete:
	@skaffold delete --profile={{SKAFFOLD_PROFILE}}

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

# Package and push helm chart.
package-push-chart:
	@helm package .deploy/charts/microservice \
		--dependency-update \
		--app-version={{DFULLTAG}} \
		--version={{DFULLTAG}} \
		--destination {{TMPDIR}}
	
	# TODO
	# @helm push [chart] [remote] [flags]