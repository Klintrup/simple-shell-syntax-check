#!/usr/bin/env bash

find_shell_from_shebang() {
  local fn_file="${1}"
  local fn_shell
  fn_shell=$(head -n 1 "${fn_file}" | awk 'BEGIN{FS="/"} /^#!\/usr\/bin\/env/{split($NF,a," "); print a[2]; exit} /^#!\//{print $NF; exit}')
  # if no shebang, assume bash
  if [ -z "${fn_shell}" ]
  then
   echo "unable to identify shell for ${fn_file}, assuming bash"
   fn_shell="bash"
  fi
  echo "${fn_shell}"
}

echo "shell=$(find_shell_from_shebang "${1}")" >> "${GITHUB_OUTPUT}"
