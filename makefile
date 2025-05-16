#! Unless changing the project or how its compiled this should not require any changes
COMMA:=,
PRINT_DIRECTORY_CHANGES:=--no-print-directory
ifeq ($(OS),Windows_NT)
	SHELL=cmd.exe
	PROJECT_DIRECTORY:=$(shell cd)
	# Drive mount point directory (The drive letter)
	MOUNT_POINT:=$(firstword $(subst :,: ,${PROJECT_DIRECTORY}))
	NUM_THREADS:=$(shell echo %NUMBER_OF_PROCESSORS%)
	FIX_PATH=$(patsubst %\,%,$(subst /,\,$1))
	RM=del /q /f 
	RMDIR=rmdir /q /s 
	MKDIR=mkdir
	GET_SUB_DIRECTORIES=$(foreach path,$1,$(shell dir /b /s /ad "$(call FIX_PATH,$(PROJECT_DIRECTORY)${path})") $(PROJECT_DIRECTORY)${path})
	PATH_SEPARATOR:=\\
	IGNORE_STDERR=2>nul
	IGNORE_STDOUT:=>nul
	HOST_OS:=windows
else
	PROJECT_DIRECTORY:=$(shell pwd)
# Drive mount point directory
	MOUNT_POINT:=$(shell df -P . | tail -1 | awk '{print $$6}')
	NUM_THREADS:=$(shell nproc)
	FIX_PATH=$(patsubst %/,%,$(subst \,/,$1))
	RM=rm -f --preserve-root
	RMDIR=rm -rf --preserve-root
	MKDIR=mkdir -p
	GET_SUB_DIRECTORIES=$(foreach path,$1,$(shell find "$(PROJECT_DIRECTORY)$(call FIX_PATH,${path})" -type d -path "*"))
	PATH_SEPARATOR:=/
	IGNORE_STDERR:=2>/dev/null
	IGNORE_STDOUT:=>/dev/null
	HOST_OS:=linux
endif
# flags to generate dependencies for all .o files
DEP_FLAGS:=-MP -MD
# Assign value only if not already set
# "make COMPILE_OS=<value> <target>" to set the COMPILE_OS to <value> before calling the make <target>
# <value> should be "windows" or "linux"
COMPILE_OS?=${HOST_OS}
ifeq ($(filter windows linux,${COMPILE_OS}),)
$(error COMPILE_OS must be 'windows' or 'linux', got '${COMPILE_OS}')
endif
# debug if not already set
# should be either "debug", "release", or "UNKNOWN"
BUILD_RELEASE?=UNKNOWN
ifeq ($(filter debug release UNKNOWN,${BUILD_RELEASE}),)
$(error ${COLOR_RED}COMPILE_TYPE must be 'debug', 'release', or 'UNKNOWN' if using target which sets this, got '${BUILD_RELEASE}')
endif
# executable if not already set
# should be either "executable", "library", or "UNKNOWN"
BUILD_TYPE?=UNKNOWN
ifeq ($(filter executable library UNKNOWN,${BUILD_TYPE}),)
$(error BUILD_TYPE must be 'executable', 'library', or 'UNKNOWN' if using target which sets this, got '${BUILD_TYPE}')
endif

# Printing colors
COLOR_BLACK:=\\u001b[30m
COLOR_RED:=\\u001b[31m
COLOR_GREEN:=\\u001b[32m
COLOR_YELLOW:=\\u001b[33m
COLOR_BLUE:=\\u001b[34m
COLOR_MAGENTA:=\\u001b[35m
COLOR_CYAN:=\\u001b[36m
COLOR_WHITE:=\\u001b[37m
COLOR_RESET:=\\u001b[0m
ECHO_COLOR=@echo -e $1 ${COLOR_RESET}

-include make-env-vars.mk

ifneq (${BUILD_TYPE},UNKNOWN)
ifneq (${BUILD_RELEASE},UNKNOWN)
$(eval ${general_config})

ifeq (${BUILD_TYPE},executable)
$(eval ${executable_config})
else
$(eval ${lib_config})
endif

ifeq (${BUILD_RELEASE},debug)
$(eval ${debug_config})
else
$(eval ${release_config})
endif

# Apply configuration based on COMPILE_OS and HOST_OS
ifeq (${HOST_OS},windows)
ifeq (${COMPILE_OS},windows)
$(eval ${windows_config})
else
$(error "Compiling for linux on windows is not supported, try using WSL")
endif
else
ifeq (${COMPILE_OS},windows)
$(eval ${windows_config})
$(eval ${windows_via_linux_config})
else
$(eval ${linux_config})
endif
endif

# Fixing paths before using them
OBJECT_OUT_DIRECTORY:=$(call FIX_PATH,${OBJECT_OUT_DIRECTORY})
PROJECT_OUT_DIRECTORY:=$(call FIX_PATH,${PROJECT_OUT_DIRECTORY})
SOURCE_DIRECTORIES:=$(call FIX_PATH,${SOURCE_DIRECTORIES})
NON_RECURSIVE_SOURCE_DIRECTORIES:=$(call FIX_PATH,${NON_RECURSIVE_SOURCE_DIRECTORIES})
LIBRARY_PREFIX:=$(call FIX_PATH,${LIBRARY_PREFIX})
GIT_LIB_PREFIX:=$(call FIX_PATH,${GIT_LIB_PREFIX})
INCLUDE_DIRECTORIES:=$(call FIX_PATH,${INCLUDE_DIRECTORIES})
LIB_DIRECTORIES:=$(call FIX_PATH,${LIB_DIRECTORIES})

INCLUDE_DIRECTORIES:=$(addprefix -I ,${INCLUDE_DIRECTORIES})
LIB_DIRECTORIES:=$(addprefix -L ,${LIB_DIRECTORIES})

# these have a ${PATH_SEPARATOR} at the end so that they follow the target rules
EXPANDED_SOURCE_DIRECTORIES:=$(patsubst %,$(PROJECT_DIRECTORY)${PATH_SEPARATOR}%,$(NON_RECURSIVE_SOURCE_DIRECTORIES)) $(call GET_SUB_DIRECTORIES,${SOURCE_DIRECTORIES})
BIN_DIRECTORIES:=$(addsuffix ${PATH_SEPARATOR},$(patsubst $(PROJECT_DIRECTORY)%,$(PROJECT_DIRECTORY)$(OBJECT_OUT_DIRECTORY)%,${EXPANDED_SOURCE_DIRECTORIES}))
SOURCE_FILES:=$(foreach Directory,${EXPANDED_SOURCE_DIRECTORIES},$(wildcard ${Directory}/*.cpp))
C_SOURCE_FILES:=$(foreach Directory,${EXPANDED_SOURCE_DIRECTORIES},$(call FIX_PATH,$(wildcard ${Directory}/*.c)))
OBJECT_FILES:=$(patsubst ${PROJECT_DIRECTORY}%,${PROJECT_DIRECTORY}$(call FIX_PATH,${OBJECT_OUT_DIRECTORY})%,$(patsubst %.cpp,%.o,${SOURCE_FILES})) \
				$(patsubst ${PROJECT_DIRECTORY}%,${PROJECT_DIRECTORY}$(call FIX_PATH,${OBJECT_OUT_DIRECTORY})%,$(patsubst %.c,%.o,${C_SOURCE_FILES}))

ifeq (${BUILD_TYPE},library)
PROJECT_FILES:=${PROJECT_DIRECTORY}${PROJECT_OUT_DIRECTORY}${PATH_SEPARATOR}lib${PROJECT_NAME}${LIB_EXTENSION}
else
PROJECT_FILES:=${PROJECT_DIRECTORY}${PROJECT_OUT_DIRECTORY}${PATH_SEPARATOR}${PROJECT_NAME}${EXECUTABLE_EXTENSION}
endif

EVERY_OBJECT:=${OBJECT_FILES}
endif
endif

.PHONY=all build-all run run-r debug release libs libs-r libs-d\
		clean clean-all win-run win-run-r win-debug win-release\
		win-libs win-libs-r win-libs-d win-clean build clean-project\
		clean-project-objects clean-project-files info help

# targets to call make with the proper parameters
# if nothing is supplied then we run the default build
all: debug
build-all:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${HOST_OS} BUILD_TYPE=executable BUILD_RELEASE=debug build
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${HOST_OS} BUILD_TYPE=library BUILD_RELEASE=debug build
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${HOST_OS} BUILD_TYPE=executable BUILD_RELEASE=release build
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${HOST_OS} BUILD_TYPE=library BUILD_RELEASE=release build
ifeq (${HOST_OS},linux)
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows BUILD_TYPE=executable BUILD_RELEASE=debug build
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows BUILD_TYPE=library BUILD_RELEASE=debug build
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows BUILD_TYPE=executable BUILD_RELEASE=release build
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows BUILD_TYPE=library BUILD_RELEASE=release build
endif
	$(call ECHO_COLOR,${COLOR_BLUE}Finished building all available builds)
run: debug
	./${PROJECT_NAME}${EXECUTABLE_EXTENSION}
run-r: release
	./${PROJECT_NAME}${EXECUTABLE_EXTENSION}
debug:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${COMPILE_OS} BUILD_TYPE=executable BUILD_RELEASE=debug build
release:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${COMPILE_OS} BUILD_TYPE=executable BUILD_RELEASE=release build
libs-all:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${HOST_OS} BUILD_TYPE=library BUILD_RELEASE=debug build
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${HOST_OS} BUILD_TYPE=library BUILD_RELEASE=release build
ifeq (${HOST_OS},linux)
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows BUILD_TYPE=library BUILD_RELEASE=debug build
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows BUILD_TYPE=library BUILD_RELEASE=release build
endif
	$(call ECHO_COLOR,${COLOR_BLUE}Finished building all libs)
libs: libs-r libs-d
	$(call ECHO_COLOR,${COLOR_BLUE}Finished building libs for ${COLOR_MAGENTA}${COMPILE_OS})
libs-r:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${COMPILE_OS} BUILD_TYPE=library BUILD_RELEASE=release build
libs-d:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${COMPILE_OS} BUILD_TYPE=library BUILD_RELEASE=debug build
clean:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${COMPILE_OS} BUILD_TYPE=library BUILD_RELEASE=release clean-project
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${COMPILE_OS} BUILD_TYPE=library BUILD_RELEASE=debug clean-project
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${COMPILE_OS} BUILD_TYPE=executable BUILD_RELEASE=release clean-project
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=${COMPILE_OS} BUILD_TYPE=executable BUILD_RELEASE=debug clean-project
	$(call ECHO_COLOR,${COLOR_BLUE}Finished cleaning all ${COLOR_MAGENTA}${COMPILE_OS}${COLOR_GREEN} builds)
clean-all:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=linux clean
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows clean
	$(call ECHO_COLOR,${COLOR_BLUE}Finished cleaning all build types)
win:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows debug
win-run:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows run
win-run-r:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows run-r
win-debug:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows debug
win-release:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows release
win-libs:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows libs
win-libs-r:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows libs-r
win-libs-d:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows libs-d
win-clean:
	@${MAKE} ${PRINT_DIRECTORY_CHANGES} COMPILE_OS=windows clean
help:
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	$(call ECHO_COLOR,${COLOR_YELLOW}------------- ${COLOR_GREEN}Makefile Help ${COLOR_YELLOW}-------------)
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	$(call ECHO_COLOR,${COLOR_YELLOW}---------------- ${COLOR_GREEN}Common ${COLOR_YELLOW}-----------------)
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	@echo make: Build the project with debug flags \(same as "make debug"\)
	@echo make debug: Build the project with debug flags
	@echo make release: Build the project with release flags
	@echo make run: Build the project with debug flags and run it
	@echo make run-r: Build the project with release flags and run it
	@echo make libs: Build release libs and debug libs
	@echo make libs-r: Build if needed with release flags and create the libs
	@echo make libs-d: Build if needed with debug flags and create the libs
	@echo make clean: Clean the the linux project files
ifeq (${HOST_OS},linux)
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	$(call ECHO_COLOR,${COLOR_YELLOW}-------- ${COLOR_GREEN}Windows Build Via Linux ${COLOR_YELLOW}--------)
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	@echo make win: Build the project with debug flags for windows \(same as "make win-debug" just shorter\)
	@echo make win-debug: Build the project with debug flags for windows
	@echo make win-release: Build the project with release flags for windows
	@echo make win-run: Build the project with debug flags for windows and run it
	@echo make win-run-r: Build the project with release flags for windows and run it
	@echo make win-libs: Build release libs and debug libs
	@echo make win-libs-r: Build the project with release flags for windows and create the libs
	@echo make win-libs-d: Build the project with debug flags for windows and create the libs
	@echo make win-clean: Clean the windows project files
endif
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
# -----------------------------------------------

ifneq (${BUILD_TYPE},UNKNOWN)
ifneq (${BUILD_RELEASE},UNKNOWN)
ifeq (${BUILD_TYPE},executable)
build: ${PROJECT_DIRECTORY}${PROJECT_OUT_DIRECTORY}${PATH_SEPARATOR} ${BIN_DIRECTORIES} ${OBJECT_FILES}
	${CPP_COMPILER} ${CPP_COMPILER_FLAGS} ${C_COMPILER_FLAGS} ${C_CPP_COMPILER_FLAGS} ${INCLUDE_DIRECTORIES} ${INCLUDE_FLAGS} -o ${PROJECT_NAME}${EXECUTABLE_EXTENSION} ${OBJECT_FILES} ${LIB_DIRECTORIES} ${LINKER_FLAGS} ${PROJECT_FINAL_FLAGS}
	$(call ECHO_COLOR,${COLOR_GREEN}Executable created for ${COLOR_MAGENTA}${COMPILE_OS}${COMMA} ${BUILD_RELEASE})
else
build: ${PROJECT_DIRECTORY}${PROJECT_OUT_DIRECTORY}${PATH_SEPARATOR} ${BIN_DIRECTORIES} ${OBJECT_FILES}
	${CREATE_LIB} $(call FIX_PATH,${PROJECT_DIRECTORY}${PROJECT_OUT_DIRECTORY}/lib${PROJECT_NAME}${LIB_EXTENSION}) ${OBJECT_FILES} ${PROJECT_FINAL_FLAGS}
	$(call ECHO_COLOR,${COLOR_GREEN}Libs created for ${COLOR_MAGENTA}${COMPILE_OS}${COMMA} ${BUILD_RELEASE})
endif

${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}%.o:${PROJECT_DIRECTORY}%.cpp
	${CPP_COMPILER} ${CPP_COMPILER_FLAGS} ${C_CPP_COMPILER_FLAGS} ${INCLUDE_DIRECTORIES} ${INCLUDE_FLAGS} ${DEP_FLAGS} -c -o ${@} ${<}

${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}%.o:${PROJECT_DIRECTORY}%.c
	${C_COMPILER} ${C_COMPILER_FLAGS} ${C_CPP_COMPILER_FLAGS} ${INCLUDE_DIRECTORIES} ${INCLUDE_FLAGS} ${DEP_FLAGS} -c -o ${@} ${<}

${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}%${PATH_SEPARATOR}:
	-@${MKDIR} ${@}
	$(call ECHO_COLOR,${COLOR_YELLOW}Created Directory: ${COLOR_MAGENTA}${@})

${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}${PATH_SEPARATOR}:
	-@${MKDIR} ${@}
	$(call ECHO_COLOR,${COLOR_YELLOW}Created Directory: ${COLOR_MAGENTA}${@})

${PROJECT_DIRECTORY}${PROJECT_OUT_DIRECTORY}${PATH_SEPARATOR}:
	-@${MKDIR} ${@}
	$(call ECHO_COLOR,${COLOR_YELLOW}Created Directory: ${COLOR_MAGENTA}${@})

clean-project: clean-project-objects clean-project-files
	$(call ECHO_COLOR,${COLOR_CYAN}Finished Cleaning for ${COLOR_MAGENTA}${COMPILE_OS}${COMMA} ${BUILD_TYPE}${COMMA} ${BUILD_RELEASE})

clean-project-objects:
	-@${RMDIR} ${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY} ${IGNORE_STDOUT} ${IGNORE_STDERR}
	$(call ECHO_COLOR,${COLOR_GREEN}Cleaned Objects for ${COLOR_MAGENTA}${COMPILE_OS}${COMMA} ${BUILD_RELEASE})

clean-project-files: 
	-@${RM} ${PROJECT_FILES} ${IGNORE_STDOUT} ${IGNORE_STDERR}
	$(call ECHO_COLOR,${COLOR_GREEN}Cleaned Project Files for ${COLOR_MAGENTA}${COMPILE_OS}${COMMA} ${BUILD_TYPE}${COMMA} ${BUILD_RELEASE})

info:
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	$(call ECHO_COLOR,${COLOR_GREEN}Info for ${COMPILE_OS} ${BUILD_TYPE} ${BUILD_RELEASE})
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	@echo C++ Compiler Flags: $(CPP_COMPILER_FLAGS)
	@echo C Compiler Flags: $(C_COMPILER_FLAGS)
	@echo C and C++ Compiler Flags: $(C_CPP_COMPILER_FLAGS)
	@echo Linker Flags: $(LINKER_FLAGS)
	@echo Include Directories: $(INCLUDE_DIRECTORIES)
	@echo Library Directories: $(LIB_DIRECTORIES)
	@echo Object Out Directory: $(OBJECT_OUT_DIRECTORY)
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	@echo Host OS \(OS the script is running on\): ${HOST_OS}
	@echo Compiled OS \(OS being compiled for\): ${COMPILE_OS}
	@echo Number of Threads: $(NUM_THREADS)
	@echo Working Directory: $(PROJECT_DIRECTORY)
	@echo Mount Point: $(MOUNT_POINT)
	@echo C++ Compiler: $(CPP_COMPILER)
	@echo C Compiler: $(C_COMPILER)
	@echo Create Lib Command: $(CREATE_LIB)
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
ifeq ($(COMPILE_OS),linux)
ifeq ($(BUILD_TYPE),executable)
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
	@echo Required Shared Libs \(if ${PROJECT_NAME} exists\):
	@echo $(shell ldd ${PROJECT_NAME} | grep -o '/[^ ]*')
	$(call ECHO_COLOR,${COLOR_YELLOW}-----------------------------------------)
endif
endif 

# include the dependencies
-include $(patsubst %.o,%.d,${EVERY_OBJECT})
endif
endif
