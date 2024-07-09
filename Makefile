###################################################
#	
#	Author : Abdullah Aldokhi
#	Github: https://github.com/codes-abdullah
# 	(Tested on Linux systems)
#	
#	While learning C++, I struggled with:
#	- Adding libraries manually to Eclipse CDT, which is nightmare.
#	- Eclipse CDT does not generate Makefile with new projects.
#	- I’ve been spoiled by Java and it’s tools for long time, debugging was a click, never thought
#	 that debugging in C++ requires different flags, which means different binary, which means
#	different launch location to make IDE's such as Eclipse CDT and Code::Blocks able to debug the app interactively.
#	- In Java, we had packages which organized our projects in a fancy way, in C++, most of the
#	source projects I’ve seen used one single directory for all source files, and probably another
#	far-away directory for header files (in project), so source nested files/dirs are not common in C++.
#	
#	As Java spoiled and well organized developer, I could not like my projects to be missy
#	which force me to learn gnu-make which I was never ever wanted to work with, hoa!!
#	
#	
#	So I spent sometime learning the basics of gnu-make and cameup with this script file.
#	This file has full support for 2 modes to resolve all mentioned cons above:
#	
#	- Declare a variable named NO_IDE with value of ‘run’ or ‘debug’ for regular projects on any
#	text editor application (remove single quotes in values)
#	- Declare a variable named IDE with value of ‘ECLIPSE’ or ‘CODE_BLOCKS’ for Eclipse
#	CDT or Code::Blocks projects accordingly (remove single quotes in values)
#	- You can’t have both to be declared (IDE and NO_IDE)
#	
#
#	Futures:
#	- Supports any nested source files/header files within main ‘src’ directory.
#	- Supports one ‘include’ directory next to ‘src’ directory, so any header files located in the
#	‘include’ directory will be including during compile time (old-school method).
#	- Libraries can be added by mentioning their names located in pkg-config, e.g: ‘glew’ library
#	named ‘glew’ with –cflags: -lGLEW -lGLU -lGL and –libs: -lGLEW -lGLU -lGL,
#	and ‘glfw’ named ‘glfw3’ with no –cflags and with –libs: -lglfw
#	modify the variable ‘INCLUDE_LIBRARY’, e.g: INCLUDE_LIBRARY := glfw3 glew
#	- Flags for Release mode can be used in ‘CXXFLAGS_BUILD’, and for debug
#	‘CXXFLAGS_DEBUG’
#
#	Targets:
#	- [all]: The main and first (default) build target, for IDE = ECLIPSE or NO_IDE = run/debug, this can be used by default for building
#	- [clean]: the main clean target, for IDE = ECLIPSE or NO_IDE = run/debug, this can be used by default, 
#	the clean target is build-context based, e.g if NO_IDE = debug, clean target will clean debug directory only,
#	also, if IDE = ECLIPSE and BUILD_MODE = run, will clean build/default directory only
#	and for IDE = CODE_BLOCKS, and MAKECMDGOALS = cleanRelease, will clean bin/Release and obj/Release only
#	- [Release]: Is a special target for IDE = CODE_BLOCKS mode, it will build the project in bin/Release and obj/Release
#	- [Debug]: Is a special target for IDE = CODE_BLOCKS mode, it will build the project in bin/Debug and obj/Debug
#	- [cleanRelease]: Is a special target for IDE = CODE_BLOCKS mode, it will clean bin/Release and Obj/release
#	- [cleanDebug]: Is a special target for IDE = CODE_BLOCKS mode, it will clean bin/Debug and obj/Debug
#	- [cleanAll]: This target will clean all known builds, such as: build/ directory for ECLIPSE and NO_IDE,
#	and bin/ and obj/ dirs for CODE_BLOCKS
#	- [createRunScript]: Create bash script named run/debug (build context based) to run application, the output of the
#	run/debug script is the project root dir, invoking this target requires sudo password to setup permissions
#	- [createBuildAndRunScript]: Create bash script named run/debug (build context based) to build and run application.
#	- [check]: internal usage
#	- [test]: internal usage
#	-
#	-
#
#	Bugs and cons:
#	- For NO_IDE and for IDE=ECLIPSE, this script supports multi target execution at once, 
#	e.g: make clean all
#	but for IDE=CODE_BLOCKS mode, only single target is supported
#	- The script will compile every single source file individually, that comes as tread-off with
#	nested source directories, so this is a ver slow process, 
#	it is highly recommended to run make with parallel flag -j, e.g: ‘make -j all’, will try in future to
#	add an option for single source directory like old-school method
#
###################################################


################# for IDE's, use ECLIPSE or CODE_BLOCKS
#IDE:=CODE_BLOCKS
#IDE:=ECLIPSE
################# for non-IDE's, specify NO_IDE, either run or debug
NO_IDE:=run
#NO_IDE:=debug
################
CXX := g++
INCLUDE_LIBRARY := glfw3 glew
CXXFLAGS_DEBUG := -g -Wall -Wextra -Wno-unused-parameter 
CXXFLAGS_BUILD := -O0 -save-temps=obj -Wall -Wextra -Wno-unused-parameter
BASH_SHELL := /bin/bash
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
################
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PROJECT_DIR := $(PROJECT_DIR:/=)
PROJECT_NAME := $(notdir $(PROJECT_DIR))
#### don't specify flags, will be inserted depending on top flags in CXXFLAGS_DEBUG and CXXFLAGS_BUILD
CXXFLAGS :=
####
SRC_DIR_NAME := src
BUILD_DIR_NAME := build
DEBUG_DIR_NAME := debug
OBJ_DIR_NAME := obj
TARGET_FILE_NAME := $(PROJECT_NAME)
####
INCLUDE_LIBRARY_CFLAGS := $(shell pkg-config --cflags $(INCLUDE_LIBRARY))
INCLUDE_LIBRARY_LIBS_FLAGS := $(shell pkg-config --libs $(INCLUDE_LIBRARY))
#####
##### DEFAULT (NO_IDE) SETUP
#####
DEFAULT_BUILD_DIR := $(PROJECT_DIR)/$(BUILD_DIR_NAME)
DEFAULT_CLEAN_DIRS :=
ifeq ($(NO_IDE),run)
	CXXFLAGS += $(CXXFLAGS_BUILD)
else ifeq ($(NO_IDE),debug)
	DEFAULT_BUILD_DIR := $(PROJECT_DIR)/$(DEBUG_DIR_NAME)
	CXXFLAGS += $(CXXFLAGS_DEBUG)
endif


DEFAULT_CLEAN_DIRS := $(DEFAULT_BUILD_DIR)
DEFAULT_BUILD_OBJ_DIR := $(DEFAULT_BUILD_DIR)/$(OBJ_DIR_NAME)
DEFAULT_BUILD_TARGET := $(DEFAULT_BUILD_DIR)/$(PROJECT_NAME)
####
DEFAULT_SRC_DIR := $(PROJECT_DIR)/$(SRC_DIR_NAME)
DEFAULT_SRC_FILES := $(shell find $(DEFAULT_SRC_DIR) -name '*.cpp' -or -name '*.c' -or -name '*.s')
DEFAULT_BUILD_OBJ_FILES := $(patsubst %.cpp, %.cpp.o, $(DEFAULT_SRC_FILES))
DEFAULT_BUILD_OBJ_FILES := $(subst $(DEFAULT_SRC_DIR),$(DEFAULT_BUILD_OBJ_DIR),$(DEFAULT_BUILD_OBJ_FILES))
####
MAKE_BUILD_DEPS := $(DEFAULT_BUILD_OBJ_FILES:.o=.d)
MAKE_DEBUG_DEPS := $(DEFAULT_DEBUG_OBJ_FILES:.o=.d)
INCLUDE_DIR := $(PROJECT_DIR)/include
INCLUDE_DIR_FLAGS := $(addprefix -I,$(INCLUDE_DIR))
CPPFLAGS ?= $(INCLUDE_DIR_FLAGS)
EXCEPTION_MSG:=
EXECUTABLE_BASH_SCRIPT_NAME := $(NO_IDE)

ifeq ($(IDE),ECLIPSE)
	BUILD_MODE ?= run
	EXECUTABLE_BASH_SCRIPT_NAME := $(BUILD_MODE)
	ifeq ($(BUILD_MODE),run)
		DEFAULT_BUILD_DIR := $(DEFAULT_BUILD_DIR)/default
		CXXFLAGS += $(CXXFLAGS_BUILD)
	else ifeq ($(BUILD_MODE),debug)
		DEFAULT_BUILD_DIR := $(DEFAULT_BUILD_DIR)/make.debug.linux.x86_64
		CXXFLAGS += $(CXXFLAGS_DEBUG)
	else
		EXCEPTION_MSG:=ECLIPSE BUILD_MODE=$(BUILD_MODE) not supported by this Makefile, you can use [run, debug or linuxtools]
	endif
	DEFAULT_BUILD_OBJ_FILES := $(subst $(DEFAULT_BUILD_OBJ_DIR),$(DEFAULT_BUILD_DIR)/obj,$(DEFAULT_BUILD_OBJ_FILES))
	DEFAULT_BUILD_OBJ_DIR := $(DEFAULT_BUILD_DIR)/obj
	DEFAULT_BUILD_TARGET := $(DEFAULT_BUILD_DIR)/$(TARGET_FILE_NAME)
	DEFAULT_CLEAN_DIRS := $(DEFAULT_BUILD_DIR)
else ifeq ($(IDE),CODE_BLOCKS)
	#ifeq logical or
	MAKECMDGOALS ?= Release
	ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),Release cleanRelease))
		DEFAULT_BUILD_DIR := $(PROJECT_DIR)/bin/Release
		TEMP_OBJ_DIR_HOLDER := $(PROJECT_DIR)/obj/Release
		DEFAULT_BUILD_TARGET := $(DEFAULT_BUILD_DIR)/$(TARGET_FILE_NAME)
		CXXFLAGS += $(CXXFLAGS_BUILD)
		EXECUTABLE_BASH_SCRIPT_NAME := run
	else ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),Debug cleanDebug))
		DEFAULT_BUILD_DIR := $(PROJECT_DIR)/bin/Debug
		TEMP_OBJ_DIR_HOLDER := $(PROJECT_DIR)/obj/Debug
		DEFAULT_BUILD_TARGET := $(DEFAULT_BUILD_DIR)/$(TARGET_FILE_NAME)
		CXXFLAGS += $(CXXFLAGS_DEBUG)
		EXECUTABLE_BASH_SCRIPT_NAME := debug
	else
		EXCEPTION_MSG:=CODE_BLOCK target=$(MAKECMDGOALS) not supported by this Makefile, you can use [Release, Debug, cleanRelease and cleanDebug] for the main time this Makefile does not supports multiple targets execution, if you have requested more than one, please retry with one target at time
	endif
	DEFAULT_BUILD_OBJ_FILES := $(subst $(DEFAULT_BUILD_OBJ_DIR),$(TEMP_OBJ_DIR_HOLDER),$(DEFAULT_BUILD_OBJ_FILES))
	DEFAULT_BUILD_OBJ_DIR := $(TEMP_OBJ_DIR_HOLDER)
	DEFAULT_BUILD_TARGET := $(DEFAULT_BUILD_DIR)/$(TARGET_FILE_NAME)
	DEFAULT_CLEAN_DIRS := $(DEFAULT_BUILD_DIR) $(DEFAULT_BUILD_OBJ_DIR)
endif
#####


DEFAULT_CLEAN_ALL_DIRS := $(PROJECT_DIR)/$(BUILD_DIR_NAME) $(PROJECT_DIR)/$(DEBUG_DIR_NAME) $(PROJECT_DIR)/bin $(PROJECT_DIR)/obj


all: check $(DEFAULT_BUILD_TARGET)
debug: all

################# CODE::BLOCKS SPECIFIC SETUP
Release: all
Debug: debug
cleanRelease: clean
cleanDebug: clean
createRunScript:
	$(eval run_script:=$(PROJECT_DIR)/$(EXECUTABLE_BASH_SCRIPT_NAME))
	$(shell echo "#!$(BASH_SHELL)\n$(DEFAULT_BUILD_TARGET)\n" > $(run_script))	
	$(shell sudo chmod +x $(run_script))
	@echo "executable bash script created: $(run_script)"
##### clear && make -j all && clear && $(DEFAULT_BUILD_TARGET)
createBuildAndRunScript:
	$(eval run_script:=$(PROJECT_DIR)/$(EXECUTABLE_BASH_SCRIPT_NAME))
	$(shell echo "#!$(BASH_SHELL)\n clear && make -j all && clear && $(DEFAULT_BUILD_TARGET)" > $(run_script))	
	$(shell sudo chmod +x $(run_script))
	@echo "executable bash script created: $(run_script)"
#####
#####



$(DEFAULT_BUILD_TARGET): $(DEFAULT_BUILD_OBJ_FILES)
	@echo "linking now: $(DEFAULT_BUILD_TARGET)"
	mkdir -p $(dir $(DEFAULT_BUILD_TARGET))
	$(CXX) $(INCLUDE_LIBRARY_CFLAGS) $^ -o $(DEFAULT_BUILD_TARGET) $(INCLUDE_LIBRARY_LIBS_FLAGS)
$(DEFAULT_BUILD_OBJ_DIR)/%.cpp.o: $(DEFAULT_SRC_DIR)/%.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c $< -o $@
	
	
check:

ifneq ($(EXCEPTION_MSG),)
	$(error $(EXCEPTION_MSG))
endif

#nothing set
ifeq ($(IDE),)
ifeq ($(NO_IDE),)
	$(error your must set IDE or NO_IDE)
endif
endif

#both set
ifneq ($(IDE),)
ifneq ($(NO_IDE),)
	$(error can't set IDE and NO_IDE at same time, use one of them only)
endif
endif

#unsupoorted IDE
ifeq ($(NO_IDE),)
ifneq ($(IDE),ECLIPSE)
ifneq ($(IDE),CODE_BLOCKS)
	$(error IDE=$(IDE) is unsupported)
endif
endif
endif

#unsupoorted NO_IDE
ifeq ($(IDE),)
ifneq ($(NO_IDE),run)
ifneq ($(NO_IDE),debug)
	$(error NO_IDE=$(NO_IDE) is unsupported)
endif
endif
endif


test: check
	@echo "IDE: $(IDE)"
	@echo "BUILD_MODE: $(BUILD_MODE)"	
	@echo "PROJECT_DIR: $(PROJECT_DIR)"
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "CXX: $(CXX)"
	@echo "CXXFLAGS: $(CXXFLAGS)"
	@echo "CPPFLAGS: $(CPPFLAGS)"
	@echo "CXXFLAGS_DEBUG: $(CXXFLAGS_DEBUG)"
	@echo "CXXFLAGS_BUILD: $(CXXFLAGS_BUILD)"
	@echo "SRC_DIR_NAME: $(SRC_DIR_NAME)"
	@echo "BUILD_DIR_NAME: $(BUILD_DIR_NAME)"
	@echo "DEBUG_DIR_NAME: $(DEBUG_DIR_NAME)"
	@echo "OBJ_DIR_NAME: $(OBJ_DIR_NAME)"
	@echo "TARGET_FILE_NAME: $(TARGET_FILE_NAME)"
	@echo "INCLUDE_LIBRARY: $(INCLUDE_LIBRARY)"
	@echo "INCLUDE_LIBRARY_CFLAGS: $(INCLUDE_LIBRARY_CFLAGS)"
	@echo "INCLUDE_LIBRARY_LIBS_FLAGS: $(INCLUDE_LIBRARY_LIBS_FLAGS)"
	@echo "DEFAULT_BUILD_DIR: $(DEFAULT_BUILD_DIR)"
	@echo "DEFAULT_BUILD_OBJ_DIR: $(DEFAULT_BUILD_OBJ_DIR)"
	@echo "DEFAULT_BUILD_OBJ_FILES: $(DEFAULT_BUILD_OBJ_FILES)"
	@echo "DEFAULT_BUILD_TARGET: $(DEFAULT_BUILD_TARGET)"
	@echo "DEFAULT_SRC_DIR: $(DEFAULT_SRC_DIR)"
	@echo "DEFAULT_SRC_FILES: $(DEFAULT_SRC_FILES)"
	@echo "MAKE_BUILD_DEPS: $(MAKE_BUILD_DEPS)"
	@echo "MAKE_DEBUG_DEPS: $(MAKE_DEBUG_DEPS)"
	@echo "INCLUDE_DIR: $(INCLUDE_DIR)"
	@echo "INCLUDE_DIR_FLAGS: $(INCLUDE_DIR_FLAGS)"


.PHONY: all clean
clean:
	rm -rf $(DEFAULT_CLEAN_DIRS) $(PROJECT_DIR)/$(EXECUTABLE_BASH_SCRIPT_NAME)
	
cleanAll:
	rm -rf $(DEFAULT_CLEAN_ALL_DIRS) $(PROJECT_DIR)/$(EXECUTABLE_BASH_SCRIPT_NAME)


