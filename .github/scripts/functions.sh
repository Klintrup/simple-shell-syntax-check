#!/usr/bin/env bash
is_shell_allowed() {
  local shell_to_check="${1}"
  local allowed_shells=("bash" "sh" "ksh" "zsh" "dash" "fish")

  for fn_shell in "${allowed_shells[@]}"; do
    if [ "${fn_shell}" == "${shell_to_check}" ]; then
      return 0
    fi
  done
  return 1
}

is_shell_available() {
  local shell_to_check="${1}"
  if command -v "${shell_to_check}" > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

find_shell_from_shebang() {
  local file="${1}"
  local fn_shell
  fn_shell=$(head -n 1 "${file}" | awk 'BEGIN{FS="/"} /^#!\/usr\/bin\/env/{split($NF,a," "); print a[2]; exit} /^#!\//{print $NF; exit}')
  echo "${fn_shell}"
}