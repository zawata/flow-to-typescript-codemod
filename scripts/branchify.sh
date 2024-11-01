#! /usr/bin/env sh

set -e

# git switch -C ts/temp/config ts/config
# git rebase development
# git switch -C ts/temp/convert

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# run the conversion
. $SCRIPT_DIR/convert.sh
rm -r migration-report.csv

git add .
git commit -m "typescriptify"

# rename .jsx?.tsx? to .jsx?
find src -name "*.jsx.tsx" | sed 's/\.jsx.tsx//' | xargs -I '{}' mv '{}.jsx.tsx' '{}.jsx'
find src -name "*.js.ts" | sed 's/\.js.ts//' | xargs -I '{}' mv '{}.js.ts' '{}.js'
git add .
git commit -m "unrename"

# revert the previous commit and rename .jsx?.tsx? to .tsx?
git revert --no-commit HEAD
find src -name "*.jsx.tsx" | sed 's/\.jsx.tsx//' | xargs -I '{}' mv '{}.jsx.tsx' '{}.tsx'
find src -name "*.js.ts" | sed 's/\.js.ts//' | xargs -I '{}' mv '{}.js.ts' '{}.ts'
git add .
# stash the second rename
git stash

# squash the conversion commit and the un-rename commits
# I don't know a better way to do this
git reset HEAD~2
git add .
git commit -m "[automatic] Typescript Migration - Part 1: Conversion"

# pop the rename stash and commit it
git stash pop
git add .
git commit -m "[automatic] Typescript Migration - Part 2: Renaming"

# cherry-pick the manual fixes commits
git cherry-pick 34028e4908a56baec2a00de51df0435ac527ffd9 # manual fixes
git cherry-pick c5f366074351ffbf985113fae81670c9c86b6b82 # react fixes

yarn bootstrap no-js-compile
yarn lint:fix || true
git add .
git commit -m "[automatic] Auto-fix lint errors"

# cherry-pick the manual fixes commits

MANUAL_FIXES_COMMITS_OLD=62320e52fb879980c091aa2d1946f0a402380732 # manually fix most remaining eslint errors
MANUAL_FIXES_COMMITS_NEW=8380ebf40eac05d0c666668307cd49cdf0455901 # pre-fix unsuppressable TS errors

git cherry-pick $MANUAL_FIXES_COMMITS_OLD~..$MANUAL_FIXES_COMMITS_NEW

git switch -C ts/config ts/temp/config
git branch -D ts/temp/config
git switch -C ts/convert ts/temp/convert
git branch -D ts/temp/convert