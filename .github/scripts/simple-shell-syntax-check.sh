#!/usr/bin/env bash

set -o nounset
set -o pipefail

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
    ((errors++))
  fi
}

. .github/scripts/functions.sh

declare -a files
if [ "${#}" -eq "0" ]; then
  while IFS= read -r line; do
    files+=("${line}")
  done < <(find . -type f -name "*.sh" -exec realpath --relative-to=. {} \;)
else
  files=("$@")
fi

declare -i errors=0
declare -i warnings=0

# check if files array contains elements and print summary header
if [ "${#files[@]}" -gt "0" ]; then
  echo "" >> "${GITHUB_STEP_SUMMARY}"
  echo "# Checked files" >> "${GITHUB_STEP_SUMMARY}"
  echo "" >> "${GITHUB_STEP_SUMMARY}"
  echo "| file | shell | status | comment |" >> "${GITHUB_STEP_SUMMARY}"
  echo "| ---- | ----- | :----: | ------- |" >> "${GITHUB_STEP_SUMMARY}"
fi

for file in "${files[@]}"; do
  echo "::group::${file}"
  echo "Checking ${file}"
  # identify shell from shebang
  shell="$(find_shell_from_shebang "${file}")"
  echo "Identified shell: ${shell}"
  # verify shell is available
  if is_shell_allowed "${shell}"; then
    if is_shell_available "${shell}"; then
      # check syntax
      check_shell_syntax "${file}" "${shell}"
    else
      echo "Unavailable shell: ${shell}"
      echo "| \`${file}\` | \`${shell}\` | :warning: | shell is not installed |" >> "${GITHUB_STEP_SUMMARY}"
      ((warnings++))
    fi
  else
    echo "Unsupported shell: ${shell}"
    echo "| \`${file}\` | \`${shell}\` | :warning: | shell is not supported |" >> "${GITHUB_STEP_SUMMARY}"
    ((warnings++))
  fi
  echo "::endgroup::"
done

# print summary if files were checked
if [ "${#files[@]}" -gt "0" ]; then
  # shellcheck disable=SC2129
  echo "" >> "${GITHUB_STEP_SUMMARY}"
  echo "# Summary" >> "${GITHUB_STEP_SUMMARY}"
  echo "" >> "${GITHUB_STEP_SUMMARY}"
  echo "::group::Summary"
  if [ "${errors}" -eq "0" ] && [ "${warnings}" -eq "0" ]; then
    echo "No errors or warnings"
    echo ":white_check_mark: No errors or warnings" >> "${GITHUB_STEP_SUMMARY}"
  else
    echo "Errors: ${errors}, Warnings: ${warnings}"
    echo ":no_entry: Errors: ${errors}, :warning: Warnings: ${warnings}" >> "${GITHUB_STEP_SUMMARY}"
    exit 1
  fi
  echo "::endgroup::"
fi
