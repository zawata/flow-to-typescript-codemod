#! /usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ignored_paths=(
    ./src/images \
    ./src/keyBindings \
    ./src/less \
    ./src/main/static \
    ./src/main/upgradeScripts \
    ./src/menus \
    ./src/references \
    ./src/releaseNotes \
    ./src/render/static \
    ./src/strings \
    ./src/svg-icons \
    ./src/templates
)

${SCRIPT_DIR}/../bin.js convert \
  --delete \
  --write \
  --skipNoFlow \
  --appendExtension \
  --useStrictAnyFunctionType \
  --useStrictAnyObjectType \
  --format=csv \
  --output ./migration-report.csv \
  -p ./src/ \
  --ignore ${ignored_paths[@]}
