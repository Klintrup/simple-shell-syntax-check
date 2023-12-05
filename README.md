---
title: "Simple shell syntax checker"
author: Søren Klintrup
params:
  headings: ["# Title", "## Head", "### Item"]
---

# Simple shell syntax checker

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/c12b74a6c6504e88b38ea605ff2d5352)](https://app.codacy.com/gh/Klintrup/simple-shell-syntax-check/dashboard)
[![License Apache 2.0](https://img.shields.io/github/license/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/releases)
[![Contributors](https://img.shields.io/github/contributors-anon/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/graphs/contributors)
[![Issues](https://img.shields.io/github/issues/Klintrup/simple-shell-syntax-check)](https://github.com/Klintrup/simple-shell-syntax-check/issues)
[![build](https://img.shields.io/github/actions/workflow/status/Klintrup/simple-shell-syntax-check/lint-shell.yml)](https://github.com/Klintrup/simple-shell-syntax-check/actions/workflows/lint-shell.yml)

Locates all shellscripts (\*.sh) in a folder, identifies the shell, and runs
`$shell -n` to validate that the script syntax is ok.

The purpose of this action is to identify syntax errors within a script, it
does not guarantee that the script will run successfully.

## supported shells

- sh
- bash
- dash
- fish
- ksh
- zsh

The shell must exist on the runner to be able to test.

### Installing shell on public runners

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
- uses: actions/checkout@v4
- uses: Klintrup/simple-shell-syntax-check@v2
```

### Install fish before running action

```yaml
- uses: actions/checkout@v4
- run: sudo apt-get install -y fish
- uses: Klintrup/simple-shell-syntax-check@v2
```

### Only validate files if changed (for pull request)

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
- name: Install shells
  if: steps.changed-files.outputs.any_changed == 'true'
  run: sudo apt-get install -y fish ksh zsh
- uses: Klintrup/simple-shell-syntax-check@v2
  if: steps.changed-files.outputs.any_changed == 'true'
  with:
    files: ${{ steps.changed-files.outputs.all_changed_and_modified_files }}
```
