VERSION               := $(shell echo $(shell git describe --tags) | sed 's/^v//')
COMMIT                := $(shell git log -1 --format='%H')
TOOLS_DESTDIR         ?= $(GOPATH)/bin
GOLANGCI_LINT         = $(TOOLS_DESTDIR)/golangci-lint
GOLANGCI_LINT_HASHSUM := 8d21cc95da8d3daf8321ac40091456fc26123c964d7c2281d339d431f2f4c840

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir 	:= $(dir $(mkfile_path))

all: ci-lint ci-test install

###############################################################################
# Build / Install
###############################################################################

LD_FLAGS = -X github.com/cybercongress/cyberindex/cmd.Version=$(VERSION) \
	-X github.com/cybercongress/cyberindex/cmd.Commit=$(COMMIT)

BUILD_FLAGS := -ldflags '$(LD_FLAGS)'

build: go.sum
ifeq ($(OS),Windows_NT)
	@echo "building cyberindex binary..."
	@go build -mod=readonly $(BUILD_FLAGS) -o build/cyberindex.exe .
else
	@echo "building cyberindex binary..."
	@go build -mod=readonly $(BUILD_FLAGS) -o build/cyberindex .
endif

install: go.sum
	@echo "installing cyberindex binary..."
	@go install $(BUILD_FLAGS) .

###############################################################################
# Build / Run in Docker
###############################################################################

docker:
	@sh scripts/start-docker.sh

###############################################################################
# Tools
###############################################################################

tools-stamp: $(GOLANGCI_LINT)
	@touch $@

tools: tools-stamp

golangci-lint: $(GOLANGCI_LINT)
$(GOLANGCI_LINT): $(mkfile_dir)/contrib/install-golangci-lint.sh
	@echo "installing golangci-lint..."
	@bash $(mkfile_dir)/contrib/install-golangci-lint.sh $(TOOLS_DESTDIR) $(GOLANGCI_LINT_HASHSUM)

###############################################################################
# Tests / CI
###############################################################################

coverage:
	@echo "viewing test coverage..."
	@go tool cover --html=coverage.out

ci-test:
	@echo "executing unit tests..."
	@go test -mod=readonly -v -coverprofile coverage.out ./... 

ci-lint:
	@echo "running GolangCI-Lint..."
	@GO111MODULE=on golangci-lint run
	@echo "formatting..."
	@find . -name '*.go' -type f -not -path "*.git*" | xargs gofmt -d -s
	@echo "verifying modules..."
	@go mod verify

clean:
	rm -f tools-stamp ./build/**

.PHONY: install build ci-test ci-lint tools tools-stamp coverage clean
