#-- Project Settings
PROJECT_NAME := Odincraft
PROJECT_DESCRIPTION := A simple Minecraft clone written in Odin using OpenGL.
PROJECT_VERSION := 0.0.0
SOURCE_DIR := ./src/
TESTS_DIR := ./tests/
BUILD_DIR := ./build/
DIST_DIR := ./dist/

#-- Target Configuration
EXE_NAME := odincraft
EXE_NAME_DEBUG := $(EXE_NAME)-debug
EXE_NAME_TESTS := $(EXE_NAME)-tests
ARCHIVE_NAME := odincraft.zip

#-- Tool Configuration
ODIN_COMPILER ?= odin
ODIN_BUILD_FLAGS ?= -build-mode:exe
ODIN_BUILD_RELEASE_FLAGS ?= -o:minimal
ODIN_BUILD_DEBUG_FLAGS ?= -o:none -debug
ODIN_CHECK_FLAGS ?= -strict-style -vet-unused -vet-shadowing -vet-using-stmt	\
					-vet-using-param -vet-style -vet-semicolon -disallow-do		\
					-thread-count:4
ODIN_TEST_FLAGS ?= -o:none -debug -collection:src=$(SOURCE_DIR)					\
				   -collection:test_utils=$(TESTS_DIR)/utils -all-packages
ODIN_DEFINES += -define:PROJECT_NAME="$(PROJECT_NAME)"							\
				-define:PROJECT_VERSION="$(PROJECT_VERSION)"					\
				-define:PROJECT_DESCRIPTION="$(PROJECT_DESCRIPTION)"

#-- Windows-specific
ifeq ($(OS),Windows_NT)
	ODIN_BUILD_RELEASE_FLAGS += -subsystem:windows
	ODIN_COMPILER := $(addsuffix .exe,$(ODIN_COMPILER))
	EXE_NAME := $(addsuffix .exe,$(EXE_NAME))
	EXE_NAME_DEBUG := $(addsuffix .exe,$(EXE_NAME_DEBUG))
	EXE_NAME_TESTS := $(addsuffix .exe,$(EXE_NAME_TESTS))
	7ZIP ?= 7z.exe
else
	7ZIP ?= 7zz
endif

#-- Path Sanitization
SOURCE_DIR := $(abspath $(SOURCE_DIR))
TESTS_DIR := $(abspath $(TESTS_DIR))
BUILD_DIR := $(abspath $(BUILD_DIR))
DIST_DIR := $(abspath $(DIST_DIR))

#-- Source File Detection
SOURCE_FILES := $(wildcard $(SOURCE_DIR)/*.odin)								\
				$(wildcard $(SOURCE_DIR)/**/*.odin)

#-- Output Goals
$(BUILD_DIR)/$(EXE_NAME): $(SOURCE_FILES) | $(BUILD_DIR)
	@echo "Building $@"
	$(ODIN_COMPILER) build $(SOURCE_DIR) -out:$@ $(ODIN_BASE_FLAGS)				\
		$(ODIN_BUILD_FLAGS) $(ODIN_BUILD_RELEASE_FLAGS) $(ODIN_DEFINES)

$(BUILD_DIR)/$(EXE_NAME_DEBUG): $(SOURCE_FILES) | $(BUILD_DIR)
	@echo "Building $@"
	$(ODIN_COMPILER) build $(SOURCE_DIR) -out:$@ $(ODIN_BASE_FLAGS)				\
		$(ODIN_BUILD_FLAGS) $(ODIN_BUILD_DEBUG_FLAGS) $(ODIN_DEFINES)

$(DIST_DIR)/$(EXE_NAME): $(BUILD_DIR)/$(EXE_NAME) | $(DIST_DIR)
	@echo "Copying executable"
	@cp $(BUILD_DIR)/$(EXE_NAME) $(DIST_DIR)/$(EXE_NAME)

$(ARCHIVE_NAME): $(DIST_DIR)/$(EXE_NAME)
	@echo "Creating $@"
	$(7ZIP) a -mx9 $@ $(DIST_DIR)/*

#-- Directory Creation Goals
$(BUILD_DIR):
	@echo "Creating \"$(BUILD_DIR)\"..."
	@mkdir -p $(BUILD_DIR)

$(DIST_DIR):
	@echo "Creating \"$(DIST_DIR)\"..."
	@mkdir -p $(DIST_DIR)

#-- Environment Debugging Goals
.PHONY: print-env
print-env:
	@echo "=== Project Configuration ==="
	@echo "Project Name: $(PROJECT_NAME)"
	@echo "Project Description: $(PROJECT_DESCRIPTION)"
	@echo "Project Version: $(PROJECT_VERSION)"
	@echo "Source Directory: $(SOURCE_DIR)"
	@echo "Tests Directory: $(TESTS_DIR)"
	@echo "Output Directory: $(BUILD_DIR)"
	@echo ""
	@echo "=== Make Environment ==="
	@echo "Odin Compiler: $(ODIN_COMPILER)"
	@echo "Make: $(MAKE)"
	@echo "Release Output: $(EXE_NAME)"
	@echo "Debug Output: $(EXE_NAME_DEBUG)"
	@echo "Tests Output: $(EXE_NAME_TESTS)"
	@echo ""
	@echo "=== Odin Environment ==="
	@$(ODIN_COMPILER) report

NULL :=
SPACE := $(NULL) $(NULL)

.PHONY: print-sources
print-sources:
	@echo "=== Source Files ==="
	@echo "$(subst $(SPACE),\n,$(SOURCE_FILES))"

#-- Aliased Goals
.DEFAULT_GOAL := default

.PHONY: pre-default
pre-default:
	@echo "Building default goal..."

.PHONY: default
default: pre-default build
	@echo "Built default goal"

.PHONY: debug
debug: build-debug

.PHONY: all
all: build-all

.PHONY: pre-build-all
pre-build-all:
	@echo "Building entire project..."

.PHONY: build-all
build-all: pre-build-all build-release build-debug
	@echo "Built entire project"

.PHONY: build
build: build-release

.PHONY: pre-build-release
pre-build-release:
	@echo "Building release goal..."

.PHONY: build-release
build-release: pre-build-release $(BUILD_DIR)/$(EXE_NAME)
	@echo "Built release goal"

.PHONY: pre-build-debug
pre-build-debug:
	@echo "Building debug goal..."

.PHONY: build-debug
build-debug: pre-build-debug $(BUILD_DIR)/$(EXE_NAME_DEBUG)
	@echo "Built debug goal"

.PHONY: pre-clean
pre-clean:
	@echo "Cleaning project..."

.PHONY: clean
clean: pre-clean
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	@echo "Cleaned project"

.PHONY: pre-rebuild
pre-rebuild:
	@echo "Rebuilding whole project..."

.PHONY: rebuild
rebuild:
	@$(MAKE) -f $(firstword $(MAKEFILE_LIST)) clean
	@$(MAKE) -f $(firstword $(MAKEFILE_LIST)) build-all

.PHONY: pre-lint
pre-lint:
	@echo "Linting project..."

.PHONY: lint
lint: pre-lint
	$(ODIN_COMPILER) check $(SOURCE_DIR) $(ODIN_CHECK_FLAGS) $(ODIN_DEFINES)
	@echo "Linted project"

.PHONY: pre-test
pre-test:
	@echo "Running project tests..."

.PHONY: test
test: pre-test | $(BUILD_DIR)
	$(ODIN_COMPILER) test $(TESTS_DIR) -out:$(BUILD_DIR)/$(EXE_NAME_TESTS)		\
		$(ODIN_TEST_FLAGS) $(ODIN_DEFINES)
	@echo "Ran project tests"

.PHONY: pre-run
pre-run:
	@echo "Running project..."

.PHONY: run
run: run-release
	@echo "Ran project"

.PHONY: pre-run-release
pre-run-release:
	@echo "Running release executable..."

.PHONY: run-release
run-release: pre-run-release build-release
	@echo "=== Start Output ==="
	@echo ""
	@$(BUILD_DIR)/$(EXE_NAME)
	@echo ""
	@echo "=== End Output ==="
	@echo "Ran release executable"

.PHONY: pre-run-debug
pre-run-debug:
	@echo "Running debug executable..."

.PHONY: run-debug
run-debug: pre-run-debug build-debug
	@echo "=== Start Output ==="
	@echo ""
	@$(BUILD_DIR)/$(EXE_NAME_DEBUG)
	@echo ""
	@echo "=== End Output ==="
	@echo "Ran debug executable"

.PHONY: pre-dist
pre-dist:
	@echo "Preparing distribution..."

.PHONY: dist
dist: pre-dist $(DIST_DIR)/$(EXE_NAME)
	@echo "Distribution ready"

.PHONY: pre-archive
pre-archive:
	@echo "Preparing distirbution archive..."

.PHONY: archive
archive: pre-archive $(ARCHIVE_NAME)
	@echo "Distribution archive ready"
