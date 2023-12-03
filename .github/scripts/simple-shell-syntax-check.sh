#!/usr/bin/env bash

set -o errexit
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
    let errors++
  fi
}

function is_shell_available() {
  local shell_to_check="${1}"
  local available_shells=("bash" "sh" "ksh" "zsh" "dash" "fish")

  for shell in "${available_shells[@]}"; do
    if [ "${shell}" == "${shell_to_check}" ]; then
      return 0
    fi
  done

  return 1
}

if [ "${#}" -eq "0" ]; then
  files=$(find . -type f -name "*.sh" -exec realpath --relative-to=. {} \;)
else
  files=("$@")
fi

errors=0
available_shells=$(check_shells)
echo "Available shells: ${available_shells}"

for file in "${files[@]}"; do
  echo "" >> "${GITHUB_STEP_SUMMARY}"
  echo "# Checked files" >> "${GITHUB_STEP_SUMMARY}"
  echo "" >> "${GITHUB_STEP_SUMMARY}"

  echo "| file | shell | status | comment |" >> "${GITHUB_STEP_SUMMARY}"
  echo "| ---- | ----- | :----: | ------- |" >> "${GITHUB_STEP_SUMMARY}"
  echo "::group::${file}"
  echo "Checking ${file}"
  # identify shell from shebang
  shell=$(head -n 1 "${file}" | awk 'BEGIN{FS="/"} /^#!\/usr\/bin\/env/{split($NF,a," "); print a[2]; exit} /^#!\//{print $NF; exit}')
  # if no shebang, assume bash
  if [ -z "${shell}" ]; then shell="bash"; fi

  echo "Identified shell: ${shell}"

  # verify shell is available
  if ! is_shell_available "${shell}"; then
    echo "Unsupported shell: ${shell}"
    echo "| \`${file}\` | \`${shell}\` | :no_entry: | Unsupported shell |" >> "${GITHUB_STEP_SUMMARY}"
    let warnings++
  fi

  # check syntax
  check_shell_syntax "${file}" "${shell}"
  echo "::endgroup::"
done

# print summary if files were checked
if [ "${#files[@]}" -gt "0" ]; then
  echo "" >> "${GITHUB_STEP_SUMMARY}"
  echo "# Summary" >> "${GITHUB_STEP_SUMMARY}"
  echo "" >> "${GITHUB_STEP_SUMMARY}"
  echo "::group::Summary"
  if [ "${errors}" -eq "0" ] || [ "${warnings}" -eq "0" ]; then
    echo "No errors or warnings"
    echo ":white_check_mark: No errors or warnings" >> "${GITHUB_STEP_SUMMARY}"
  else
    echo "Errors: ${errors}, Warnings: ${warnings}"
    echo ":no_entry: Errors: ${errors}, Warnings: ${warnings}" >> "${GITHUB_STEP_SUMMARY}"
    exit 1
  fi
  echo "::endgroup::"
fi
