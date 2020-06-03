#!/bin/bash -e

cwd=$(pwd)

cd "${cwd}/website"
npm install

npm run build

cd "${cwd}"


# - build netlifycmsoauth
# - build deploy netlifycmsoauth
# - build frontend
# - deploy frontend infrastrucuture
# - push frontend objects
# - build go bin with frontend static assets
# - ensure lambda bucket
# - push go bin zip to lambda bucket
# - apply remaining backend infrastructure
