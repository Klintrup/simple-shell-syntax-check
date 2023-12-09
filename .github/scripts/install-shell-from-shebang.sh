#!/usr/bin/env bash

find_shell_from_shebang() {
  local fn_file="${1}"
  local fn_shell
  fn_shell=$(head -n 1 "${fn_file}" | awk 'BEGIN{FS="/"} /^#!\/usr\/bin\/env/{split($NF,a," "); print a[2]; exit} /^#!\//{print $NF; exit}')
  echo "${fn_shell}"
}

install_package() {
  local package="${1}"
  . /etc/os-release
  case $ID in
      debian|ubuntu|linuxmint)
          sudo apt-get install -y "${package}"
          ;;
      centos|rhel|fedora)
          sudo yum install -y "${package}"
          ;;
      opensuse*)
          sudo zypper install -y "${package}"
          ;;
      *)
          echo "Unsupported distribution, please install ${package} manually."
          ;;
  esac
}

install_shell_if_missing() {
  local shell="${1}"
  if ! which "${shell}" > /dev/null 2>&1; then
    echo "${shell} is not installed, installing..."
    install_package "${shell}"
  else
    echo "${shell} is already installed"
  fi
}

while [ "${#}" -gt "0" ]; do
  shell="$(find_shell_from_shebang "${1}")"
  echo ::group::"${shell}"
  install_shell_if_missing "${shell}"
  echo "shell identified as ${shell}"
  echo ::endgroup::
  shift
done