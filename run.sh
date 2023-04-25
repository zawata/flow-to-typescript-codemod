#! /usr/bin/env sh

REPO_ROOT=$(realpath ../repos/GitKraken)

ignored_paths=(
    ${REPO_ROOT}/src/images \
    ${REPO_ROOT}/src/keyBindings \
    ${REPO_ROOT}/src/less \
    ${REPO_ROOT}/src/main/static \
    ${REPO_ROOT}/src/main/uppgradeScripts \
    ${REPO_ROOT}/src/menus \
    ${REPO_ROOT}/src/references \
    ${REPO_ROOT}/src/releaseNotes \
    ${REPO_ROOT}/src/render/static \
    ${REPO_ROOT}/src/spec \
    ${REPO_ROOT}/src/strings \
    ${REPO_ROOT}/src/svg-icons \
    ${REPO_ROOT}/src/templates
)

yarn typescriptify convert \
  --delete \
  --write \
  -p ${REPO_ROOT}/src/ \
  --ignore ${ignored_paths[@]}
