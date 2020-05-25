#!/bin/bash -e

go_mains=$(find ./cmd -name "main.go")

version=$(git describe --always)

rm -rf "dist/"

for go_main in ${go_mains}; do
  bin_name="${go_main//\//_}"
  bin_name="${bin_name//_main.go/}"
  bin_name="${bin_name//._cmd_/}"
  bin_name="${bin_name}_${version}"
  echo "-> compiling ${bin_name}"
  CGO_ENABLED=0 go build -ldflags "-X github.com/VJftw/vote-for-policies/pkg/cmd.BuildVersion=${version}" -o "dist/${bin_name}/main" "${go_main}"

  zip -j "dist/${bin_name}.zip" "dist/${bin_name}/main"
done

