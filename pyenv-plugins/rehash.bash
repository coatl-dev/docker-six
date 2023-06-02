#!/usr/bin/env bash
# Source: https://gist.github.com/LarsFronius/4d3167dfd0df168d2ab50576e3ebd315
# Install this file into ${PYENV_ROOT}/plugins/pyenv-rehash/etc/pyenv.d/exec/rehash.bash
#
# Executes pyenv-rehash on invocation of any pyenv shimmed executable in ${PYENV_ROOT}/shims/

set -e

# Remove pyenv-exec from $@
shift 1

STATUS=0
"$PYENV_COMMAND_PATH" "$@" || STATUS="$?"

# Run `pyenv-rehash` after a successful installation.
if [ "$STATUS" == "0" ]; then
  pyenv-rehash
fi

exit "$STATUS"
