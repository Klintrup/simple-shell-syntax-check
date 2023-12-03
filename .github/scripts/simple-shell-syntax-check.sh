#!/bin/sh
for file in $(find . -type f -name '*.sh'); do
  # github actions markdown summary file
  echo "| file | shell | status | comment |" >> $GITHUB_STEP_SUMMARY
  echo "| ---- | ----- | :----: | ------- |" >> $GITHUB_STEP_SUMMARY
  echo "::group::${file}"
  echo "Checking ${file}"
  
  # get the shell from the shebang line with support for env
  shell=$(head -n 1 "${file}" | awk 'BEGIN{FS="/"} /^#!\/usr\/bin\/env/{split($NF,a," "); print a[2]; exit} /^#!\//{print $NF; exit}')

  # verify that shell variable is a supported shell
  case ${shell} in
    bash | sh) ;;
    *)
      echo "Unsupported shell: ${shell}"
      echo "| \`${file}\` | \`${shell}\` | :no_entry: | Unsupported shell |" >> $GITHUB_STEP_SUMMARY
      exit 1
      ;;
  esac
  ${shell} -n "${file}"
  syntaxexitcode=${?}
  if [ ${syntaxexitcode} -eq 0 ]; then
    echo "${file} check OK with ${shell}"
    echo "| \`${file}\` | \`${shell}\` | :white_check_mark: | |" >> $GITHUB_STEP_SUMMARY
  else
    echo "${file} check FAIL with ${shell}"
    echo "| \`${file}\` | \`${shell}\` | :no_entry: | see run log |" >> $GITHUB_STEP_SUMMARY
    exit ${syntaxexitcode}
  fi
  echo "::endgroup::"
done
