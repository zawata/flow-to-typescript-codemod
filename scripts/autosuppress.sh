#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# I hijacked the jiraSlug to be a comment for the auto-suppression. just didn't feel like renaming it
node $SCRIPT_DIR/../bin.js fix --autoSuppressErrors --removeUnused --jiraSlug='auto-suppressed by typescriptify'
