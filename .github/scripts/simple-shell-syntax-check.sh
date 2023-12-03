#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

shopt -s globstar

check_shell_syntax() {
  local file="${1}"
  local shell="${2}"

  "${shell}" -n "${file}"
  syntaxexitcode="${?}"
  if [ "${syntaxexitcode}" -eq 0 ]; then
    echo "${file} check OK with ${shell}"
    echo "| \`${file}\` | \`${shell}\` | :white_check_mark: | |" >> "${GITHUB_STEP_SUMMARY}"
  else
    echo "${file} check FAIL with ${shell}"
    echo "| \`${file}\` | \`${shell}\` | :no_entry: | see run log |" >> "${GITHUB_STEP_SUMMARY}"
    exit ${syntaxexitcode}
  fi
}

if [ "${#}" -eq "0" ]; then
  files=(**/*.sh)
else
  files=("$@")
fi

for file in "${files[@]}"; do
  echo "| file | shell | status | comment |" >> "${GITHUB_STEP_SUMMARY}"
  echo "| ---- | ----- | :----: | ------- |" >> "${GITHUB_STEP_SUMMARY}"
  echo "::group::${file}"
  echo "Checking ${file}"
  shell=$(head -n 1 "${file}" | awk 'BEGIN{FS="/"} /^#!\/usr\/bin\/env/{split($NF,a," "); print a[2]; exit} /^#!\//{print $NF; exit}')
  case ${shell} in
    bash | sh) ;;
    *)
      echo "Unsupported shell: ${shell}"
      echo "| \`${file}\` | \`${shell}\` | :no_entry: | Unsupported shell |" >> "${GITHUB_STEP_SUMMARY}"
      exit 1
      ;;
  esac
  check_shell_syntax "${file}" "${shell}"
  echo "::endgroup::"
done