# Project Definitions
## General Settings
PROJECT_NAME := Odincraft
PROJECT_VERSION := 0.0.0
PROJECT_DESCRIPTION := A simple Minecraft clone written in Odin using OpenGL.

## Project Directories
SOURCE_DIR := src
LIB_DIR := lib
TEST_DIR := tests
BUILD_DIR := build
DIST_DIR := dist

## Target Settings
TARGET_NAME_BASE := odincraft
TARGET_NAME_DEBUG := $(TARGET_NAME_BASE)-debug
TARGET_NAME_RELEASE := $(TARGET_NAME_BASE)
TARGET_NAME_TESTS := $(TARGET_NAME_BASE)-tests
TARGET_NAME_ARCHIVE_BASE := $(TARGET_NAME_BASE)-$(PROJECT_VERSION)
TARGET_NAME_ARCHIVE_DEBUG := $(TARGET_NAME_ARCHIVE_BASE)-debug.zip
TARGET_NAME_ARCHIVE_RELEASE := $(TARGET_NAME_ARCHIVE_BASE)-release.zip

## Compiler Settings
ODIN_COMPILER ?= odin
ARCHIVER ?= 7zz
ODIN_BUILD_FLAGS ?= -build-mode:exe
ODIN_BUILD_FLAGS_DEBUG ?= -o:none -debug
ODIN_BUILD_FLAGS_RELEASE ?= -o:minimal
ODIN_TEST_FLAGS ?= -o:none -debug
ODIN_CHECK_FLAGS_SOURCE ?= -strict-style -vet-unused -vet-shadowing				\
						   -vet-using-stmt -vet-using-param -vet-style 			\
						   -vet-semicolon -disallow-do -thread-count:4
ODIN_CHECK_FLAGS_TESTS ?= -strict-style -vet-unused -vet-shadowing				\
						  -vet-using-stmt -vet-using-param -vet-style			\
						  -vet-semicolon -disallow-do -thread-count:4			\
						  -no-entry-point
ODIN_BUILD_COLLECTIONS ?= lib=$(LIB_DIR)
ODIN_TEST_COLLECTIONS ?= lib=$(LIB_DIR) src=$(SOURCE_DIR)						\
						 test_utils=$(TEST_DIR)/utils
ODIN_DEFINES ?= PROJECT_NAME="$(PROJECT_NAME)"									\
				PROJECT_VERSION="$(PROJECT_VERSION)"							\
				PROJECT_DESCRIPTION="$(PROJECT_DESCRIPTION)"

#!! Do not edit below this line unless you know what you're doing !!

# Windows-specific adjustments

ifeq ($(OS),Windows_NT)
	#-- Make sure we build against the GUI version of the Windows API
	ODIN_BUILD_FLAGS_RELEASE += -subsystem:windows
	#-- Add `.exe` to various file names
	ODIN_COMPILER := $(addsuffix .exe, $(ODIN_COMPILER))
	TARGET_NAME_DEBUG := $(addsuffix .exe, $(TARGET_NAME_DEBUG))
	TARGET_NAME_RELEASE := $(addsuffix .exe, $(TARGET_NAME_RELEASE))
	TARGET_NAME_TESTS := $(addsuffix .exe, $(TARGET_NAME_TESTS))
	#-- 7-zip is just called 7z on Windows where as it's 7zz on other systems
	ARCHIVER := 7z.exe
endif

#-- Sanitize all directories so they don't interfere with alias targets
SOURCE_DIR := $(abspath $(SOURCE_DIR))
LIB_DIR := $(abspath $(LIB_DIR))
TEST_DIR := $(abspath $(TEST_DIR))
BUILD_DIR := $(abspath $(BUILD_DIR))
DIST_DIR := $(abspath $(DIST_DIR))

#-- Determine Odin source files
SOURCE_FILES := $(wildcard $(SOURCE_DIR)/*.odin)								\
				$(wildcard $(SOURCE_DIR)/**/*.odin)

#-- Main build goals
$(BUILD_DIR)/$(TARGET_NAME_DEBUG): $(SOURCE_FILES) | $(BUILD_DIR)
	@echo "Building $(TARGET_NAME_DEBUG)..."
	$(ODIN_COMPILER) build $(SOURCE_DIR)										\
		-out:$(BUILD_DIR)/$(TARGET_NAME_DEBUG)									\
		$(ODIN_BUILD_FLAGS) $(ODIN_BUILD_FLAGS_DEBUG)							\
		$(foreach collect,$(ODIN_BUILD_COLLECTIONS),-collection:$(collect))		\
		$(foreach define,$(ODIN_DEFINES),-define:$(define))
	@echo "Built $(TARGET_NAME_DEBUG)"

$(BUILD_DIR)/$(TARGET_NAME_RELEASE): $(SOURCE_FILES) | $(BUILD_DIR)
	@echo "Building $(TARGET_NAME_RELEASE)..."
	$(ODIN_COMPILER) build $(SOURCE_DIR)										\
		-out:$(BUILD_DIR)/$(TARGET_NAME_RELEASE)								\
		$(ODIN_BUILD_FLAGS) $(ODIN_BUILD_FLAGS_RELEASE)							\
		$(foreach collect,$(ODIN_BUILD_COLLECTIONS),-collection:$(collect))		\
		$(foreach define,$(ODIN_DEFINES),-define:$(define))
	@echo "Built $(TARGET_NAME_RELEASE)"

#-- Archive goals

$(DIST_DIR)/$(TARGET_NAME_ARCHIVE_DEBUG): $(BUILD_DIR)/$(TARGET_NAME_DEBUG) | $(DIST_DIR)
	@echo "Creating $(TARGET_NAME_ARCHIVE_DEBUG)..."
	$(ARCHIVER) a -mx=9 $(DIST_DIR)/$(TARGET_NAME_ARCHIVE_DEBUG)				\
		$(BUILD_DIR)/$(TARGET_NAME_DEBUG)

$(DIST_DIR)/$(TARGET_NAME_ARCHIVE_RELEASE): $(BUILD_DIR)/$(TARGET_NAME_RELEASE) | $(DIST_DIR)
	@echo "Creating $(TARGET_NAME_ARCHIVE_RELEASE)..."
	$(ARCHIVER) a -mx=9 $(DIST_DIR)/$(TARGET_NAME_ARCHIVE_RELEASE)				\
		$(BUILD_DIR)/$(TARGET_NAME_RELEASE)

#-- Directory creation goals

$(BUILD_DIR):
	@echo "Creating '$(BUILD_DIR)' directory..."
	@mkdir -p $(BUILD_DIR)

$(DIST_DIR):
	@echo "Creating '$(DIST_DIR)' directory..."
	@mkdir -p $(DIST_DIR)

#-- Build goals

.PHONY: pre-build-release
pre-build-release:
	@echo "Building release goal..."

.PHONY: build-release
build-release: pre-build-release $(BUILD_DIR)/$(TARGET_NAME_RELEASE)
	@echo "Built release goal"

.PHONY: pre-build-debug
pre-build-debug:
	@echo "Building debug goal..."

.PHONY: build-debug
build-debug: pre-build-debug $(BUILD_DIR)/$(TARGET_NAME_DEBUG)
	@echo "Built debug goal"

.PHONY: pre-build
pre-build:
	@echo "Building default goal..."

.PHONY: build
build: pre-build build-release
	@echo "Built default goal"

.PHONY: pre-build-all
pre-build-all:
	@echo "Building all goals..."

.PHONY: build-all
build-all: pre-build-all build-debug build-release
	@echo "Built all goals"

#-- Clean goals

.PHONY: pre-clean-debug
pre-clean-debug:
	@echo "Running debug clean goal..."

.PHONY: clean-debug
clean-debug: pre-clean-debug
	@echo "Cleaning '$(BUILD_DIR)/$(TARGET_NAME_DEBUG)'..."
	@rm -rf $(BUILD_DIR)/$(TARGET_NAME_DEBUG)
ifeq ($(OS),Windows_NT)
	@rm -rf $(BUILD_DIR)/$(subst .exe,.pdb,$(TARGET_NAME_DEBUG))
endif
	@echo "Ran debug clean goal"

.PHONY: pre-clean-release
pre-clean-release:
	@echo "Running release clean goal..."

.PHONY: clean-release
clean-release: pre-clean-release
	@echo "Cleaning '$(BUILD_DIR)/$(TARGET_NAME_RELEASE)'..."
	@rm -rf $(BUILD_DIR)/$(TARGET_NAME_RELEASE)
	@echo "Ran release clean goal"

.PHONY: pre-clean-build
pre-clean-build:
	@echo "Running build clean goal..."

.PHONY: clean-build
clean-build: pre-clean-build clean-debug clean-release
	@echo "Ran build clean goal"

.PHONY: pre-clean-archive-debug
pre-clean-archive-debug:
	@echo "Running debug archive clean goal..."

.PHONY: clean-archive-debug
clean-archive-debug: pre-clean-archive-debug
	@echo "Cleaning '$(DIST_DIR)/$(TARGET_NAME_ARCHIVE_DEBUG)'..."
	@rm -rf $(DIST_DIR)/$(TARGET_NAME_ARCHIVE_DEBUG)
	@echo "Ran debug archive clean goal"

.PHONY: pre-clean-archive-release
pre-clean-archive-release:
	@echo "Running release archive clean goal..."

.PHONY: clean-archive-release
clean-archive-release: pre-clean-archive-release
	@echo "Cleaning '$(DIST_DIR)/$(TARGET_NAME_ARCHIVE_RELEASE)'..."
	@rm -rf $(DIST_DIR)/$(TARGET_NAME_ARCHIVE_RELEASE)
	@echo "Ran release archive clean goal"

.PHONY: pre-clean-archive
pre-clean-archive:
	@echo "Running archive clean goal..."

.PHONY: clean-archive
clean-archive: pre-clean-archive clean-archive-debug clean-archive-release
	@echo "Ran archive clean goal"

.PHONY: pre-clean-tests
pre-clean-tests:
	@echo "Running tests clean goal..."

.PHONY: clean-tests
clean-tests: pre-clean-tests
	@echo "Cleaning '$(BUILD_DIR)/$(TARGET_NAME_TESTS)'..."
	@rm -rf $(BUILD_DIR)/$(TARGET_NAME_TESTS)
ifeq ($(OS),Windows_NT)
	@echo "Cleaning '$(BUILD_DIR)/$(subst .exe,.pdb,$(TARGET_NAME_TESTS))'..."
	@rm -rf $(BUILD_DIR)/$(subst .exe,.pdb,$(TARGET_NAME_TESTS))
endif
	@echo "Ran tests clean goal"

.PHONY: pre-clean
pre-clean:
	@echo "Running default clean goal..."

.PHONY: clean
clean: pre-clean clean-build clean-archive clean-tests
	@echo "Ran default clean goal"

.PHONY: pre-clean-all
pre-clean-all:
	@echo "Running all clean goal..."

.PHONY: clean-all
clean-all: pre-clean-all clean-build clean-archive clean-tests
	@echo "Ran all clean goal"

#-- Archive goals

.PHONY: pre-archive
pre-archive:
	@echo "Running default archive goal..."

.PHONY: archive
archive: pre-archive archive-release
	@echo "Ran default archive goal"

.PHONY: pre-archive-release
pre-archive-release:
	@echo "Running release archive goal..."

.PHONY: archive-release
archive-release: pre-archive-release $(DIST_DIR)/$(TARGET_NAME_ARCHIVE_RELEASE)
	@echo "Ran release archive goal"

.PHONY: pre-archive-debug
pre-archive-debug:
	@echo "Running debug archive goal..."

.PHONY: archive-debug
archive-debug: pre-archive-debug $(DIST_DIR)/$(TARGET_NAME_ARCHIVE_DEBUG)
	@echo "Ran debug archive goal"

#-- Test goals

.PHONY: pre-test
pre-test:
	@echo "Running default test goal..."

.PHONY: test
test: pre-test
	$(ODIN_COMPILER) test $(TEST_DIR)											\
		$(ODIN_TEST_FLAGS)														\
		-out:$(BUILD_DIR)/$(TARGET_NAME_TESTS)									\
		$(foreach collect,$(ODIN_TEST_COLLECTIONS),-collection:$(collect))		\
		$(foreach define,$(ODIN_DEFINES),-define:$(define))
	@echo "Ran default test goal"

#-- Lint goals

.PHONY: pre-lint-source
pre-lint-source:
	@echo "Running source lint goal..."

.PHONY: lint-source
lint-source: pre-lint-source
	$(ODIN_COMPILER) check $(SOURCE_DIR)										\
		$(ODIN_CHECK_FLAGS_SOURCE)														\
		$(foreach define,$(ODIN_DEFINES),-define:$(define))
	@echo "Ran source lint goal"

.PHONY: pre-lint-tests
pre-lint-tests:
	@echo "Running tests lint goal..."

.PHONY: lint-tests
lint-tests: pre-lint-tests
	$(ODIN_COMPILER) check $(TEST_DIR)										\
		$(ODIN_CHECK_FLAGS_TESTS)														\
		$(foreach define,$(ODIN_DEFINES),-define:$(define))
	@echo "Ran tests lint goal"

.PHONY: pre-lint
pre-lint:
	@echo "Running default lint goal..."

.PHONY: lint
lint: pre-lint lint-source lint-tests
	@echo "Ran default lint goal"

.PHONY: pre-lint-all
pre-lint-all:
	@echo "Running all lint goal..."

.PHONY: lint-all
lint-all: pre-lint-all lint
	@echo "Ran all lint goal"

#-- General goals

.DEFAULT_GOAL := default

.PHONY: default
default: build

.PHONY: all
all: build-all
