#!/usr/bin/env bash

find_shell_from_shebang() {
  local fn_file="${1}"
  local fn_shell
  fn_shell=$(head -n 1 "${fn_file}" | awk 'BEGIN{FS="/"} /^#!\/usr\/bin\/env/{split($NF,a," "); print a[2]; exit} /^#!\//{print $NF; exit}')
  echo "${fn_shell}"
}

is_supported_shell() {
  local shell="${1}"
  case "${shell}" in
    sh | bash | dash | fish | ksh | zsh)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

install_package() {
  local package="${1}"
  . /etc/os-release
  case $ID in
    debian | ubuntu | linuxmint)
      sudo apt-get install -y "${package}"
      ;;
    centos | rhel | fedora)
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

declare -a files
if [ "${#}" -eq "0" ]; then
  while IFS= read -r line; do
    files+=("${line}")
  done < <(find . -type f -name "*.sh" -exec realpath --relative-to=. {} \;)
else
  files=("$@")
fi

for for_file in "${files[@]}"; do
  echo ::group::"${for_file}"
  shell="$(find_shell_from_shebang "${for_file}")"
  if is_supported_shell "${for_file}"; then
    echo "shell identified as ${for_file}"
    install_shell_if_missing "${for_file}"
  else
    echo "unsupported shell ${for_file}, skipping"
  fi
  echo ::endgroup::
done
