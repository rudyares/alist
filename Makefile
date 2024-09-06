# Current datetime
TIMESTAMP ?= $(shell date +%Y%m%d%H%M%S)
IMAGE_NAME ?= ghcr.io/rudyares/alist
IMAGE_TAG ?= v0.0.1
IMAGE = $(IMAGE_NAME):$(IMAGE_TAG)-$(TIMESTAMP)

goVersion = $(shell go version | sed 's/go version //')
gitCommit=$(shell git log --pretty=format:"%h" -1)
version = $(IMAGE_TAG)
webVersion = $(shell wget -qO- -t1 -T2 "https://api.github.com/repos/alist-org/alist-web/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')

ldflags="\
-w -s \
-X 'github.com/alist-org/alist/v3/internal/conf.BuiltAt=$(TIMESTAMP)' \
-X 'github.com/alist-org/alist/v3/internal/conf.GoVersion=$(goVersion)' \
-X 'github.com/alist-org/alist/v3/internal/conf.GitAuthor=rudyares' \
-X 'github.com/alist-org/alist/v3/internal/conf.GitCommit=$(gitCommit)' \
-X 'github.com/alist-org/alist/v3/internal/conf.Version=$(version)' \
-X 'github.com/alist-org/alist/v3/internal/conf.WebVersion=$(webVersion)' \
"
extldflags="--extldflags '-static -fpic' "$(ldflags)

.PHONY: fmt
fmt: ## Run go fmt
	go fmt ./...

.PHONY: mod-tidy
mod-tidy: ## Run go mod tidy
	go mod tidy

.PHONY: build
build: fmt mod-tidy ## build binary
	@echo "> Build binary ..."
	@GOOS=linux GOARCH=amd64 CGO_ENABLED=1 CC=x86_64-unknown-linux-gnu-gcc go build -o ./bin/alist-linux-amd64 -ldflags=${extldflags} -tags=jsoniter .
	@GOOS=darwin GOARCH=arm64 go build -o ./bin/alist-darwin-arm64 -ldflags=${ldflags} -tags=jsoniter .
	@echo "(^_^) Build binary successfully"

.PHONY: build-image-unidas
build-docker-image: build # build docker image
	@echo "> Build docker image ..."
	@docker build -t ${IMAGE} -f ./self.dockerfile . --platform=linux/amd64
	@echo "(^_^) Build docker image successfully"

.PHONY: fetch-web
fetch-web:  ## fetch web packages
	@echo "> Fetching web ..."
	@curl -L https://github.com/alist-org/alist-web/releases/latest/download/dist.tar.gz -o dist.tar.gz
	@rm -rf public/dist
	@tar -xzf dist.tar.gz -C public/
	@rm -rf dist.tar.gz
	@echo "(^_^) Fetching web successfully"


