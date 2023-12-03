#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

check_shell_syntax()
                     {
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

check_shells()
               {
  local local_shells=("bash" "sh" "ksh" "zsh" "dash" "fish")
  local local_available_shells=()

  for shell in "${local_shells[@]}"; do
    if command -v "${shell}" > /dev/null 2>&1; then
      local_available_shells+=("${shell}")
    fi
  done

  IFS="|"
  echo "${local_available_shells[*]}"
}

if [ "${#}" -eq "0" ]; then
  files=$(find . -type f -name "*.sh" -exec realpath --relative-to=. {} \;)
else
  files=("$@")
fi

available_shells=$(check_shells)
echo "Available shells: ${available_shells}"

for file in "${files[@]}"; do
  echo "| file | shell | status | comment |" >> "${GITHUB_STEP_SUMMARY}"
  echo "| ---- | ----- | :----: | ------- |" >> "${GITHUB_STEP_SUMMARY}"
  echo "::group::${file}"
  echo "Checking ${file}"
  shell=$(head -n 1 "${file}" | awk 'BEGIN{FS="/"} /^#!\/usr\/bin\/env/{split($NF,a," "); print a[2]; exit} /^#!\//{print $NF; exit}')
  case ${shell} in
    ${available_shells}) ;;
    *)
        echo "Unsupported shell: ${shell}"
        echo "| \`${file}\` | \`${shell}\` | :no_entry: | Unsupported shell |" >> "${GITHUB_STEP_SUMMARY}"
        exit 1
        ;;
  esac
  check_shell_syntax "${file}" "${shell}"
  echo "::endgroup::"
done
