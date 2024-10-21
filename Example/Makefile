# Environment Variables

PRODUCT_NAME := andpad-camera
SCHEME_NAME := andpad-camera-Example

MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFILE_PATH := $(MAKEFILE_DIR)/Makefile
GEMFILE_PATH := $(MAKEFILE_DIR)/../Gemfile
XCODEPROJ_PATH := $(MAKEFILE_DIR)/$(PRODUCT_NAME).xcworkspace

make := make -f $(MAKEFILE_PATH)

# Public Commands

default: app

## 環境構築して、Xcodeプロジェクトを開きます。
.PHONY: app
app:
	$(make) check-ruby
	$(make) gem
	$(make) cocoapods
	$(make) open

## 環境構築の生成物やアプリのキャッシュを削除します。
.PHONY: clean
clean:
	$(make) clean-client
	$(make) clean-client-caches
	$(make) clean-gem

# Internal Commands

.PHONY: open
open:
	xed $(MAKEFILE_DIR)/$(PRODUCT_NAME).xcworkspace
	@echo "✅ $@"

.PHONY: clean-client
clean-client:
	rm -rf $(MAKEFILE_DIR)/Pods
	@echo "✅ $@"

.PHONY: clean-client-caches
clean-client-caches:
	find $(HOME)/Library/Developer/Xcode/DerivedData/ \
		-name $(PRODUCT_NAME)"*" \
		-maxdepth 1 \
		-print \
		-type d \
		-exec \
			rm -rf {} \;
	@echo "✅ $@"

## Gem

.PHONY: gem
gem:
	bundle install --gemfile $(GEMFILE_PATH)
	@echo "✅ $@"

.PHONY: check-gem
check-gem:
	bundle check --gemfile $(GEMFILE_PATH)
	@echo "✅ $@"

.PHONY: clean-gem
clean-gem:
	rm -rf $(MAKEFILE_DIR)/../vendor
	@echo "✅ $@"

.PHONY: _update-gem
_update-gem:
ifndef L
	@echo "make _update-gem L=<ライブラリ名を指定してください>"
	@exit 1
endif
	bundle update --gemfile $(GEMFILE_PATH) $(L)
	@echo "✅ $@"

## CocoaPods

.PHONY: cocoapods
cocoapods:
	bundle exec --gemfile $(GEMFILE_PATH) \
		pod install --repo-update
	@echo "✅ $@"

## Ruby

## .ruby-versionに指定されているRubyバージョンがインストールされているかチェックします。
.PHONY: check-ruby
check-ruby:
	@if [ ! -f ../.ruby-version ]; then \
		echo ".ruby-version file not found in the parent directory"; \
		exit 1; \
	fi; \
	RUBY_VERSION=$$(cat ../.ruby-version); \
	CURRENT_RUBY_VERSION=$$(ruby -v | awk '{print $$2}'); \
	if [ "$$RUBY_VERSION" = "$$CURRENT_RUBY_VERSION" ]; then \
		echo "Ruby version matches .ruby-version: $$RUBY_VERSION"; \
	else \
		echo "Ruby version does not match .ruby-version"; \
		echo "Expected: $$RUBY_VERSION, but got: $$CURRENT_RUBY_VERSION"; \
		echo "Please install Ruby version $$RUBY_VERSION. If you manage Ruby versions with rbenv installed via brew, run \`make setup-ruby\`."; \
		exit 1; \
	fi
	@echo "✅ $@"

## .ruby-versionに指定されているRubyバージョンをbrewを使ってインストールします。
.PHONY: setup-ruby
setup-ruby:
	@if [ ! -f ../.ruby-version ]; then \
		echo ".ruby-version file not found in the parent directory"; \
		exit 1; \
	fi
	@RUBY_VERSION=$$(cat ../.ruby-version); \
	if ! command -v rbenv > /dev/null; then \
		brew install rbenv; \
	fi; \
	if ! brew list ruby-build > /dev/null 2>&1; then \
		brew install ruby-build; \
	fi; \
	if ! rbenv versions | grep -q "$$RUBY_VERSION"; then \
		brew upgrade ruby-build; \
		rbenv install $$RUBY_VERSION; \
		cd .. && rbenv local $$RUBY_VERSION; \
		eval "$$(rbenv init -)"; \
		rbenv rehash; \
		ruby -v; \
	fi
	@echo "✅ $@";
