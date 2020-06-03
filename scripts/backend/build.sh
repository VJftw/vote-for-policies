#!/bin/bash -e

go_mains=$(find ./cmd -name "main.go")

version=$(git describe --always)

rm -rf "dist/"

go mod vendor

statik -dest ./pkg/voteforpolicies/result -src website/dist/survey/index.html

lambda=$1
main_path="cmd/lambda/${lambda}/main.go"
bin_name="${version}_${lambda}"

echo "-> compiling ${bin_name}"
CGO_ENABLED=0 go build -ldflags "-X github.com/VJftw/vote-for-policies/pkg/cmd.BuildVersion=${version}" -o "dist/${bin_name}/main" "${main_path}"

zip -j "dist/${bin_name}.zip" "dist/${bin_name}/main"
