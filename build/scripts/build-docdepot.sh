#!/bin/bash -e
cp -r repo/docdepot /go/src/
cp -f version/number /go/src/docdepot/data/version

pushd /go/src/docdepot
go get -u github.com/go-bindata/go-bindata/...
go-bindata data/...
go get
GOOS=${ARCH} go build
popd

find /go/src/docdepot -type f -executable -exec mv {} output/docdepot-${ARCH} \;
