#!/bin/bash -e

cwd=$(pwd)

cd "${cwd}/website"
npm install

npm run build

cd "${cwd}"
