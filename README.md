# Simple shell syntax checker

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/c12b74a6c6504e88b38ea605ff2d5352)](https://app.codacy.com/gh/Klintrup/simple-shell-syntax-check/dashboard)
[![License Apache 2.0](https://img.shields.io/github/license/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/releases)
[![Contributors](https://img.shields.io/github/contributors-anon/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/graphs/contributors)
[![Issues](https://img.shields.io/github/issues/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/issues)
[![build](https://img.shields.io/github/actions/workflow/status/Klintrup/simple-shell-syntax-check/lint.yml)](https://github.com/Klintrup/simple-shell-syntax-check/actions/workflows/lint.yml)

## Description

This GitHub Action, named "Simple Shell Syntax Check", is designed to perform
syntax checks on shell scripts. The action takes an optional input 'files'. If
provided, it will check the syntax of these specific files. If not provided,
locate all .sh files in the current folder.

## Inputs

| Input                 | required | Description                     |
| --------------------- | -------- | ------------------------------- |
| files                 | no       | list of files to be checked     |
| install_missing_shell | no       | Find missing shells and install |

## Output

Outputs status of each file to the action summary

## supported shells

- `sh`
- `bash`
- `dash`
- `fish`
- `ksh`
- `zsh`

The shell must exist on the runner to be able to test. If the shell doesn't
exist, that test will fail.

### Installing shell on ubuntu-latest runner

You can install the shell before using this action

```yaml
- name: Install fish
  run: sudo apt-get install -y fish
```

Or you can install all "missing" shells in a single command

```yaml
- name: Install fish, ksh and zsh
  run: sudo apt-get install -y fish ksh zsh
```

## instructions

### Simple install (check all files named .sh)

```yaml
- uses: actions/checkout@b3b4b1a
- uses: Klintrup/simple-shell-syntax-check@v2
```

### Install fish before running action

```yaml
- uses: actions/checkout@b3b4b1a
- run: sudo apt-get install -y fish
- uses: Klintrup/simple-shell-syntax-check@v2
```

### Only validate files if changed (for pull request)

```yaml
- uses: actions/checkout@b3b4b1a
  with:
    ref: ${{ github.head_ref }}
    fetch-depth: 0
- name: Get changed files
  id: changed-files
  uses: tj-actions/changed-files@v40
  with:
    files: |
      **.sh
- uses: Klintrup/simple-shell-syntax-check@v2
  if: steps.changed-files.outputs.any_changed == 'true'
  with:
    files: ${{ steps.changed-files.outputs.all_changed_and_modified_files }}
    install_missing_shell: true
```
