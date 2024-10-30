#! /usr/bin/env sh

set -e

# git switch -C ts/temp/config ts/config
# git rebase development

git switch -C ts/temp/convert
cd ../flow-to-typescript-codemod
./run.sh
cd -
git add .
git commit -m "typescriptify"

# rename .jsx?.tsx? to .jsx?
find src/ -name '*.jsx.tsx' -exec rename .jsx.tsx .jsx {} +
find src/ -name '*.js.ts' -exec rename .js.ts .js {} +
git add .
git commit -m "typescriptify - unrename"

# revert the previous commit and rename .jsx?.tsx? to .tsx?
git revert --no-commit HEAD
find src/ -name '*.jsx.tsx' -exec rename .jsx.tsx .tsx {} +
find src/ -name '*.js.ts' -exec rename .js.ts .ts {} +
git add .
# stash the second rename
git stash

# squash the conversion commit and the un-rename commits
# I don't know a better way to do this
git reset HEAD~2
git add .
git commit -m "typescriptify - convert"

# pop the rename stash and commit it
git stash pop
git add .
git commit -m "typescriptify - rename"

# cherry-pick the manual fixes commits
git cherry-pick 17d249379c5247c63d615b4a9a095f10e3631c37 # manual fixes
git cherry-pick f135938d2e1bc8c0d00925c042d134f2f2c1d1ff # react fixes

yarn bootstrap no-js-compile
yarn lint:fix || true
git add .
git commit -m "typescriptify - lint"
git cherry-pick ed15e52098897c21bdca6c3b7117883e8c879e4d && # remaining eslint errors
git cherry-pick a78e65faf495564a94ac5a436d0a37f058a33341 && # auto-suppress eslint errors
git cherry-pick ebb2479e9c2b65b7fa876f089415b31a3c7e284b && # remove unused suppressions
git cherry-pick fe55b1f2bdbf0cbf72457fa2f1cc9cf5322dbbad && # reflow eslint-disable-line comments
git cherry-pick c8e383726df991ae84ba1c568f80c9b17263147b && # remove jsdoc returns
git cherry-pick 2f26006a5fcd664c58edc00d2af81e3b0b8a6131 && # misc type improvments
git cherry-pick 8724ec1ab6a0767d5b2c72c2bd235cfbb8606edb && # fix lock types
git cherry-pick e8e75a20bf9772fd1ad8f6c7b218d8cd1ebd111d && # more type fixes

git switch -C ts/config ts/temp/config
git branch -D ts/temp/config
git switch -C ts/convert ts/temp/convert
git branch -D ts/temp/convert