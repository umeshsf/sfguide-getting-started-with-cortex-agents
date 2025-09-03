#!/bin/bash

set -euo pipefail

WORKINGDIR="${PWD}"
cd $(dirname $0)
MYDIR="$(pwd -P)"
SRCDIR=$(git rev-parse --show-toplevel)

VERSION=${VERSION-v7.14.0}

docker run \
  -u $(id -u):$(id -g) \
  -v "${WORKINGDIR}:/inout" \
  -v "${SRCDIR}:/src" \
  -w "/inout" \
  openapitools/openapi-generator-cli:${VERSION} \
  generate \
  -i cortexagent-run.yaml \
  -o pyclient.build \
  -g python \
  --skip-operation-example \
  --additional-properties=useOneOfDiscriminatorLookup=true

rsync -r --include "*" pyclient.build/openapi_client/models .
rm -rf pyclient.build
find ./models -type f -name "*.py" -exec sed -i '' 's|from openapi_client.models.|from models.|g' {} +
