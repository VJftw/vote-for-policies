#!/bin/bash -e

destGoPkgDir="${PWD}/pkg/voteforpolicies/result"
templatesDir="${PWD}/pkg/voteforpolicies/result/templates"
baseTemplateDest="${templatesDir}/base.html"
baseTemplate="${PWD}/website/dist/survey/go-base-template/index.html"

cp "${baseTemplate}" "${baseTemplateDest}"

sed -i '/id="result">/a {{ template "content" . }}' "${baseTemplateDest}"

go get github.com/rakyll/statik
statik -dest "${destGoPkgDir}" -src "${templatesDir}"

rm "${baseTemplateDest}"
