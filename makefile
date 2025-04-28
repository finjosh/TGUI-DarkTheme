#* This makefile is made to work with my environment and may not work with others
#* ALL paths should start with a / and end without one

COMMA:=,
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
else
	PROJECT_DIRECTORY:=$(shell pwd)
# Drive mount point directory
	MOUNT_POINT:=$(shell df -P . | tail -1 | awk '{print $$6}')
	NUM_THREADS:=$(shell nproc)
	FIX_PATH=$(patsubst %/,%,$(subst \,/,$1))
	RM=rm --preserve-root
	RMDIR=rm -r --preserve-root
	MKDIR=mkdir -p
	GET_SUB_DIRECTORIES=$(foreach path,$1,$(shell find "$(PROJECT_DIRECTORY)$(call FIX_PATH,${path})" -type d -path "*"))
	PATH_SEPARATOR:=/
	IGNORE_STDERR:=2>/dev/null
	IGNORE_STDOUT:=>/dev/null
endif
# flags to generate dependencies for all .o files
DEP_FLAGS:=-MP -MD
#* Everything above here should not require any changes

#! "make" by default will compile in debug to compile with release flags use "make release"

#*** Cross Platform Values ***
#*****************************
MAKEFLAGS:=-j$(NUM_THREADS)
CPP_COMPILER:=g++
DEBUG_FLAGS:=-g -D _DEBUG
RELEASE_FLAGS:=-O3
# any other compiler options (warning flags -Wextra -Wall)
GENERAL_COMPILER_FLAGS:=-std=c++20
EXE_NAME:=main
LIB_NAME:=dark_light_theme
# Where the source files will be found (recursive)
SOURCE_DIRECTORIES=/src
# Where you don't want underlying folder/files to be included
NON_RECURSIVE_SOURCE_DIRECTORIES=/
LIB_SOURCE_DIRECTORIES=/src
#*****************************
#*****************************

#*** Platform Specific Values ***
#********************************
ifeq ($(OS),Windows_NT)
	EXE:=.exe
	LIBRARY_PREFIX:=${MOUNT_POINT}\dev-env\libraries\windows
	GIT_LIB_PREFIX:=$(MOUNT_POINT)\dev-env\git-projects
	INCLUDE_DIRECTORIES=${LIBRARY_PREFIX}\SFML-3.0.0\include ${LIBRARY_PREFIX}\TGUI-1.7\include ${PROJECT_DIRECTORY} ${PROJECT_DIRECTORY}\include ${GIT_LIB_PREFIX}\cpp-Utilities\include
	LIB_DIRECTORIES=${LIBRARY_PREFIX}\SFML-3.0.0\lib ${LIBRARY_PREFIX}\TGUI-1.7\lib ${GIT_LIB_PREFIX}\cpp-Utilities\lib\windows
	LINKER_FLAGS:=-ltgui-s \
					-lsfml-graphics-s -lsfml-window-s -lsfml-system-s -lopengl32 -lfreetype \
					-lsfml-window-s -lsfml-system-s -lopengl32 -lwinmm -lgdi32 \
					-lsfml-audio-s -lsfml-system-s -lFLAC -lvorbisenc -lvorbisfile -lvorbis -logg \
					-lsfml-network-s -lsfml-system-s -lws2_32 \
					-lsfml-system-s -lwinmm \
					-lstdc++ 
	INCLUDE_FLAGS:=-D SFML_STATIC
	COMPILE_OPTIONS:=${GENERAL_COMPILER_FLAGS} -static

# Where the object files will be saved
# Will be generated if non existent
	OBJECT_OUT_DIRECTORY=/bin/windows
# Will be generated if non existent
	LIB_OUT_DIRECTORY=/lib/windows
	LIB_EXTENSION:=.a
	CREATE_LIB:=ar rcs 
	LIB_COMPILE_FLAGS:=
else
	EXE:=
# this is hardcoded for now
	LIBRARY_PREFIX:=$(MOUNT_POINT)/dev-env/libraries/linux
	GIT_LIB_PREFIX:=$(MOUNT_POINT)/dev-env/git-projects
	INCLUDE_DIRECTORIES=/usr/include ${PROJECT_DIRECTORY} ${PROJECT_DIRECTORY}/include ${LIBRARY_PREFIX}/TGUI-1.8.0/include ${GIT_LIB_PREFIX}/cpp-Utilities/include
	LIB_DIRECTORIES=/usr/lib ${LIBRARY_PREFIX}/TGUI-1.8.0/lib ${GIT_LIB_PREFIX}/cpp-Utilities/lib/linux
# where to search for sharded libs other than the default locations
# ${LIB_DIRECTORIES} is used for simple testing during compiling
	LIBS_SEARCH_PATH:=./ ./lib \
					  ${LIB_DIRECTORIES}
	LINKER_FLAGS:=-ltgui \
					-lsfml-graphics -lsfml-window -lsfml-system \
					-lsfml-window -lsfml-system \
					-lsfml-audio -lsfml-system \
					-lsfml-network \
					-lsfml-system \
					-lstdc++ $(patsubst %,-Wl${COMMA}-rpath${COMMA}%,${LIBS_SEARCH_PATH})
	INCLUDE_FLAGS:=
	COMPILE_OPTIONS:=${GENERAL_COMPILER_FLAGS} 

# Where the object files will be saved
# Will be generated if non existent
	OBJECT_OUT_DIRECTORY=/bin/linux
# Will be generated if non existent
	LIB_OUT_DIRECTORY=/lib/linux
	LIB_EXTENSION:=.so
	CREATE_LIB:=g++ -shared -o
	LIB_COMPILE_FLAGS:=-fPIC
endif
#********************************
#********************************

OBJECT_OUT_DIRECTORY:=$(call FIX_PATH, ${OBJECT_OUT_DIRECTORY})
LIB_OUT_DIRECTORY:=$(call FIX_PATH, ${LIB_OUT_DIRECTORY})
SOURCE_DIRECTORIES:=$(call FIX_PATH, ${SOURCE_DIRECTORIES})
NON_RECURSIVE_SOURCE_DIRECTORIES:=$(call FIX_PATH, ${NON_RECURSIVE_SOURCE_DIRECTORIES})
OBJECT_OUT_DIRECTORY:=$(call FIX_PATH, ${OBJECT_OUT_DIRECTORY})
LIB_OUT_DIRECTORY:=$(call FIX_PATH, ${LIB_OUT_DIRECTORY})
LIB_SOURCE_DIRECTORIES:=$(call FIX_PATH, ${LIB_SOURCE_DIRECTORIES})
INCLUDE_DIRECTORIES:=$(call FIX_PATH,$(addprefix -I ,${INCLUDE_DIRECTORIES}))
LIB_DIRECTORIES:=$(call FIX_PATH,$(addprefix -L ,${LIB_DIRECTORIES}))

EVERY_SOURCE:=$(foreach Directory,${EXPANDED_SOURCE_DIRECTORIES},$(wildcard ${Directory}/*.cpp)) $(foreach Directory,${EXPANDED_SOURCE_DIRECTORIES},$(wildcard ${Directory}/*.cpp))
# # include the dependencies
-include $(patsubst %.cpp,%.d,${EVERY_SOURCE})

.PHONY = all info clean libs libs-r libs-d run clean_objects clean_exe clean_libs debug release

all: debug
run: debug
	./${EXE_NAME}${EXE}

run-r: release
	./${EXE_NAME}${EXE}

# these have a ${PATH_SEPARATOR} at the end so that they follow the target rules
BIN_DIRECTORIES=$(addsuffix ${PATH_SEPARATOR},$(foreach dir,${EXPANDED_SOURCE_DIRECTORIES},$(patsubst $(PROJECT_DIRECTORY)%,$(PROJECT_DIRECTORY)$(OBJECT_OUT_DIRECTORY)%,$(dir))))
EXPANDED_SOURCE_DIRECTORIES=$(PROJECT_DIRECTORY)$(NON_RECURSIVE_SOURCE_DIRECTORIES) $(call GET_SUB_DIRECTORIES,${SOURCE_DIRECTORIES})
SOURCE_FILES=$(foreach Directory,${EXPANDED_SOURCE_DIRECTORIES},$(call FIX_PATH,$(wildcard ${Directory}/*.cpp)))
OBJECT_FILES=$(patsubst ${PROJECT_DIRECTORY}%,${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}%,$(patsubst %.cpp,%.o,${SOURCE_FILES}))

# these have a ${PATH_SEPARATOR} at the end so that they follow the target rules
LIB_BIN_DIRECTORIES=$(addsuffix ${PATH_SEPARATOR},$(foreach dir,${LIB_EXPANDED_SOURCE_DIRECTORIES},$(patsubst $(PROJECT_DIRECTORY)%,$(PROJECT_DIRECTORY)$(OBJECT_OUT_DIRECTORY)%,$(dir))))
LIB_EXPANDED_SOURCE_DIRECTORIES=$(call GET_SUB_DIRECTORIES,${LIB_SOURCE_DIRECTORIES})
LIB_SOURCE_FILES=$(foreach Directory,${LIB_EXPANDED_SOURCE_DIRECTORIES},$(call FIX_PATH,$(wildcard ${Directory}/*.cpp)))
LIB_OBJECT_FILES=$(patsubst ${PROJECT_DIRECTORY}%,${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}%,$(patsubst %.cpp,%.o,${LIB_SOURCE_FILES}))

debug: CURRENT_FLAGS=${DEBUG_FLAGS} ${COMPILE_OPTIONS} 
debug: ${BIN_DIRECTORIES} ${OBJECT_FILES}
	${CPP_COMPILER} ${CURRENT_FLAGS} ${INCLUDE_DIRECTORIES} ${INCLUDE_FLAGS} -o ${EXE_NAME} ${OBJECT_FILES} ${LIB_DIRECTORIES} ${LINKER_FLAGS}

release: CURRENT_FLAGS=${RELEASE_FLAGS} ${COMPILE_OPTIONS} 
release: ${BIN_DIRECTORIES} ${OBJECT_FILES}
	${CPP_COMPILER} ${CURRENT_FLAGS} ${INCLUDE_DIRECTORIES} ${INCLUDE_FLAGS} -o ${EXE_NAME} ${OBJECT_FILES} ${LIB_DIRECTORIES} ${LINKER_FLAGS}

${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}%.o:${PROJECT_DIRECTORY}%.cpp
	${CPP_COMPILER} ${CURRENT_FLAGS} ${INCLUDE_DIRECTORIES} ${INCLUDE_FLAGS} ${DEP_FLAGS} -c -o ${@} ${<}

libs:
	make clean_objects && make libs-r && make clean_objects && make libs-d

# build the lib with the same compile options
libs-r: CURRENT_FLAGS = ${COMPILE_OPTIONS} ${RELEASE_FLAGS} ${LIB_COMPILE_FLAGS}
libs-r: ${PROJECT_DIRECTORY}${LIB_OUT_DIRECTORY}${PATH_SEPARATOR} ${LIB_BIN_DIRECTORIES} ${LIB_OBJECT_FILES}
	${CREATE_LIB} $(call FIX_PATH,${PROJECT_DIRECTORY}${LIB_OUT_DIRECTORY}/lib${LIB_NAME}${LIB_EXTENSION}) ${LIB_OBJECT_FILES}
	@echo Release Libs created

libs-d: CURRENT_FLAGS = ${COMPILE_OPTIONS} ${DEBUG_FLAGS} ${LIB_COMPILE_FLAGS}
libs-d: ${PROJECT_DIRECTORY}${LIB_OUT_DIRECTORY}${PATH_SEPARATOR} ${LIB_BIN_DIRECTORIES} ${LIB_OBJECT_FILES}
	${CREATE_LIB} $(call FIX_PATH,${PROJECT_DIRECTORY}${LIB_OUT_DIRECTORY}/lib${LIB_NAME}-d${LIB_EXTENSION}) ${LIB_OBJECT_FILES}
	@echo Debug Libs created

${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}%${PATH_SEPARATOR}:
	-@${MKDIR} ${@}
	@echo Created Object Directory: ${@}

${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY}${PATH_SEPARATOR}:
	-@${MKDIR} ${@}
	@echo Created Object Directory: ${@}

${PROJECT_DIRECTORY}${LIB_OUT_DIRECTORY}${PATH_SEPARATOR}:
	-@${MKDIR} ${@}
	@echo Created Lib Directory: ${@}

clean: clean_objects clean_exe clean_libs
	@echo Finished Cleaning

clean_objects:
	-@${RMDIR} ${PROJECT_DIRECTORY}${OBJECT_OUT_DIRECTORY} ${IGNORE_STDOUT} ${IGNORE_STDERR}
	@echo Cleaned Objects

clean_exe:
	-@${RM} ${PROJECT_DIRECTORY}${PATH_SEPARATOR}${EXE_NAME}${EXE} ${IGNORE_STDOUT} ${IGNORE_STDERR}
	@echo Cleaned Executable

clean_libs:
	-@${RMDIR} ${PROJECT_DIRECTORY}${LIB_OUT_DIRECTORY} ${IGNORE_STDOUT} ${IGNORE_STDERR}
	@echo Cleaned Libs

info:
	@echo -----------------------------------------
	@echo __LIB SPECIFIC FILES__
	@echo Source Directories: ${LIB_EXPANDED_SOURCE_DIRECTORIES}
	@echo Sources: ${LIB_SOURCE_FILES}
	@echo Objects: ${LIB_OBJECT_FILES}
	@echo -----------------------------------------
	@echo -----------------------------------------
	@echo __EXECUTABLE SPECIFIC FILES__
	@echo Source Directories: ${EXPANDED_SOURCE_DIRECTORIES}
	@echo Sources: ${SOURCE_FILES}
	@echo Objects: ${OBJECT_FILES}
	@echo -----------------------------------------
	@echo Debug Flags: $(DEBUG_FLAGS)
	@echo Release Flags: $(RELEASE_FLAGS)
	@echo Compiler Options \(Platform Specific\): $(COMPILE_OPTIONS)
	@echo Linker Flags \(Platform Specific\): $(LINKER_FLAGS)
	@echo Include Directories: $(INCLUDE_DIRECTORIES)
	@echo Library Directories: $(LIB_DIRECTORIES)
	@echo Bin Directory: $(OBJECT_OUT_DIRECTORY)
	@echo Lib Directory: $(LIB_OUT_DIRECTORY)
	@echo -----------------------------------------
	@echo -----------------------------------------
# Nothing means not windows
	@echo OS: $(OS)
	@echo Working Directory: $(PROJECT_DIRECTORY)
	@echo Number of Threads: $(NUM_THREADS)
	@echo Compiler: $(CPP_COMPILER)
	@echo Mount Point: $(MOUNT_POINT)
	@echo -----------------------------------------
