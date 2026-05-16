SHELL := /usr/bin/env bash
OS := $(shell uname -s)

SH_FILES := \
	bootstrap.sh \
	link-agents.sh \
	alias.sh \
	git.sh \
	settings.sh \
	homebrew.sh \
	python.sh \
	ruby.sh \
	.claude/statusline-command.sh \
	.claude/hooks/session-start.sh

.PHONY: help test-deps lint test test-connect6 check

help:
	@echo "Targets:"
	@echo "  test-deps      Install bats, shellcheck, jq (macOS: brew; Linux: apt)"
	@echo "  lint           Run shellcheck and JSON validation"
	@echo "  test           Run bats smoke tests + connect6 engine tests"
	@echo "  test-connect6  Run connect6 engine tests only"
	@echo "  check          lint + test (what CI runs)"

test-deps:
ifeq ($(OS),Darwin)
	brew install bats-core shellcheck jq
else
	sudo apt-get update && sudo apt-get install -y bats shellcheck jq
endif

lint:
	shellcheck --severity=warning $(SH_FILES)
	jq empty .claude/settings.json

test: test-connect6
	bats tests/

test-connect6:
	node --test 'connect6/tests/*.test.mjs'

check: lint test
