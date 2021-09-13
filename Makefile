GO_ROOT ?= /usr/local/go.weak
GO = ${GO_ROOT}/bin/go
GO_VERSION = $(shell ${GO} env GOVERSION)
ifndef (,$(findstring devel,${GO_VERSION}))
	GO_VERSION=$(shell git -C /usr/local/go.plugin hash)
endif
GO_FLAGS?=
GO_GCFLAGS?=
GO_LDFLAGS?=-w

GO_NEXT_COMMIT=$(shell git -C ${GO_ROOT} log --reverse --pretty=%H origin/master | grep -A 1 $$(git -C ${GO_ROOT} rev-parse $$(git -C ${GO_ROOT} hash)) | tail -n1)

.DEFAULT_GOAL = bisect

.PHONY: bisect
bisect: buildgo
	${MAKE} --no-print-directory nm/so | grep 'google.golang.org/grpc.DialContext.func1.f'

.PHONY: buildgo
buildgo:
	git -C /usr/local/go.plugin reset --hard ${GO_NEXT_COMMIT} && \
		cd /usr/local/go.plugin/src && \
		GOROOT_BOOTSTRAP=~/sdk/gotip GOGC=off ./make.bash -a -no-banner && \
		cd ${CURDIR}

.PHONY: run
run: plugin
	GOTRACEBACK=all ${GO} run -v -x $(strip ${GO_FLAGS}) -gcflags=$(strip ${GO_GCFLAGS}) -ldflags='$(strip ${GO_LDFLAGS})' main.go ./plugin/plugin-${GO_VERSION}.so

.PHONY: plugin
plugin:
	${GO} build -buildmode=plugin -o ./plugin/plugin-${GO_VERSION}.so $(strip ${GO_FLAGS}) -gcflags=$(strip ${GO_GCFLAGS}) -ldflags='$(strip ${GO_LDFLAGS})' ./plugin

.PHONY: build
build: plugin
	${GO} build -v -x -o go117-linker-issue-${GO_VERSION} $(strip ${GO_FLAGS}) -gcflags=$(strip ${GO_GCFLAGS}) -ldflags='$(strip ${GO_LDFLAGS})' .

.PHONY: nm
nm: build
	${GO} tool nm -sort name -type ./go117-linker-issue-${GO_VERSION}

.PHONY: nm/so
nm/so: plugin
	${GO} tool nm -sort name -type ./plugin-${GO_VERSION}.so
