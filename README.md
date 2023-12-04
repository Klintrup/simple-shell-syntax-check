# simple shell syntax checker

[![CodeFactor](https://www.codefactor.io/repository/github/klintrup/simple-shell-syntax-check/badge)](https://www.codefactor.io/repository/github/klintrup/simple-shell-syntax-check)
[![License Apache 2.0](https://img.shields.io/github/license/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/releases)
[![Contributors](https://img.shields.io/github/contributors-anon/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/graphs/contributors)
[![Issues](https://img.shields.io/github/issues/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/issues)
[![build](https://img.shields.io/github/actions/workflow/status/Klintrup/simple-shell-syntax-check/lint-shell.yml)](https://github.com/Klintrup/simple-shell-syntax-check/actions/workflows/lint-shell.yml)

Very simple syntax checker.

Locates all shellscripts (*.sh) in folder, identifies the shell and runs $shell -n to validate the script syntax is ok.

## supported shells

- sh  
- bash  
- dash  
- fish  
- ksh  
- zsh  

The shell must exist on the runner for the test to work.

### Installing shell on public runners

You can install the shell before using this action

```yaml
- name: Install fish
  run:  sudo apt-get install -y fish
```

## instructions

### Simple install (check all files named .sh)

```yaml
- uses: actions/checkout@v4
- uses: Klintrup/simple-shell-syntax-check@v2
```

### Install fish before running action

```yaml
- uses: actions/checkout@v4
- run:  sudo apt-get install -y fish
- uses: Klintrup/simple-shell-syntax-check@v2
```

### Only validate files if changed

```yaml
- uses: actions/checkout@v4
  with:
    ref: ${{ github.head_ref }}
    fetch-depth: 0
- name: Get changed files
  id: changed-files
  uses: tj-actions/changed-files@v40
  with:
    files: |
      **.sh
- uses: Klintrup/simple-shell-syntax-check@move-payload-to-script
  if: steps.changed-files.outputs.any_changed == 'true'
  with:
    files: ${{ steps.changed-files.outputs.all_changed_and_modified_files }}            
```
