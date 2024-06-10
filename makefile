# directory that the makefile was called from
PROJECT_DIR_TEMP:=$(patsubst %/makefile,%, $(abspath $(lastword ${MAKEFILE_LIST})))
#! DONT EDIT ABOVE THIS

# exe name
PROJECT:=main
# the directory in which all .o and .d files will be made
OBJ_O_DIR:=bin
# the include flags for compilation by default includes the project directory and include directory
INCLUDE_DIRS=/VSCodeFolder/Libraries/SFML-2.6.1/include /VSCodeFolder/Libraries/TGUI-1.2/include
# extra include flags
INCLUDE_FLAGS=-D SFML_STATIC
# the paths to libs for linking
LIB_DIRS=/VSCodeFolder/Libraries/SFML-2.6.1/lib /VSCodeFolder/Libraries/TGUI-1.2/lib
# source files directory (the project directory is automatically added)
SRC:=src
# the directory for lib files that are made with "make lib"
# this should be the full path
LIB_DIR:=${PROJECT_DIR_TEMP}/lib
# the directory where all the source files that you want in the lib are
LIB_SOURCE:=src

# compiler command
CC:=g++
# linker flags for compilation
# add "-mwindows" to disable the terminal
LINKERFLAGS:=-ltgui-s -lsfml-graphics-s -lsfml-window-s \
			-lsfml-system-s -lsfml-audio-s -lsfml-network-s \
			-lws2_32 -lflac -lvorbisenc -lvorbisfile -lvorbis \
			-logg -lopenal32 -lopengl32 -lwinmm -lgdi32 -lfreetype \
			-lstdc++
# flags to generate dependencies for all .o files
DEPFLAGS:=-MP -MD
# any compiler options
# put -Werror for warnings to be treated as errors
# use -Wextra -Wall every so often to find possible bugs
COMPILE_OPTIONS:=-std=c++20 -g -static

#! DONT EDIT ANYTHING FROM HERE DOWN

ifeq ($(OS),Windows_NT)
	EXE:=.exe
	FIXPATH=$(subst /,\,$1)
	PROJECT_DIR:=$(call FIXPATH,${PROJECT_DIR_TEMP})
	SOURCEDIRS:=$(call FIXPATH,$(shell dir ${SRC} /s /b /ad)) $(call FIXPATH,${PROJECT_DIR}/${SRC}) $(call FIXPATH,${PROJECT_DIR})
	LIBSOURCEDIRS:=$(call FIXPATH,$(shell dir "${LIB_SOURCE}" /s /b /ad)) $(call FIXPATH,${PROJECT_DIR}/${LIB_SOURCE})
	RM=del /q /f
	RMDIR=rmdir /S /Q
	MD:=mkdir
# if you are using wsl or something which requires a more exact path add it here (this path will be added in front of all lib_dirs and include_dirs)
	DRIVEPATH:=
else
	EXE:=
	FIXPATH=$(subst \,/,$1)
	PROJECT_DIR:=$(call FIXPATH,${PROJECT_DIR_TEMP})
	SOURCEDIRS:=$(shell find "$$PWD" -type d -path "*${PROJECT_DIR}/${SRC}*") ${PROJECT_DIR}
	RM=rm -r --preserve-root
	RMDIR=rm -r --preserve-root
	MD:=mkdir -p
# if you are using wsl or something which requires a more exact path add it here (this path will be added in front of all lib_dirs and include_dirs)
	DRIVEPATH:=/mnt/v
endif

INCLUDES:=$(addprefix -I ${DRIVEPATH},$(call FIXPATH,${INCLUDE_DIRS})) ${INCLUDE_FLAGS} -I ${PROJECT_DIR} -I ${PROJECT_DIR}/include
LIBS:=$(addprefix -L ${DRIVEPATH},$(call FIXPATH,${LIB_DIRS}))

# all .cpp file paths
SRC:=$(foreach D,${SOURCEDIRS},$(wildcard ${D}/*.cpp))
LIBSRC:=$(foreach D,${LIBSOURCEDIRS},$(wildcard ${D}/*.cpp))
# Create an object file of every cpp file
OBJECTS:=$(patsubst ${PROJECT_DIR}%,${PROJECT_DIR}/${OBJ_O_DIR}%,$(call FIXPATH,$(patsubst %.cpp,%.o,${SRC})))
LIBOBJECTS:=$(patsubst ${PROJECT_DIR}%,${PROJECT_DIR}/${OBJ_O_DIR}%,$(call FIXPATH,$(patsubst %.cpp,%.o,${LIBSRC})))
# Creating dependency files
DEPFILES=$(patsubst %.o,%.d,${OBJECTS})
# All bin directories
BIN_DIRS=$(foreach dir,$(call FIXPATH,$(SOURCEDIRS)),$(patsubst $(call FIXPATH,$(PROJECT_DIR)%),$(call FIXPATH,$(PROJECT_DIR)/$(OBJ_O_DIR)%),$(dir)))

# so there is no file that gets mistaked with the tasks listed
.PHONY = all info clean lib run

all: ${BIN_DIRS} ${PROJECT}

# main build
${PROJECT}: ${OBJECTS}
	${CC} ${COMPILE_OPTIONS} ${INCLUDES} -o ${@} ${^} ${LIBS} ${LINKERFLAGS}

# build objects for the main build
${PROJECT_DIR}/${OBJ_O_DIR}%.o:${PROJECT_DIR}%.cpp
	${CC} ${COMPILE_OPTIONS} ${INCLUDES} ${DEPFLAGS} -c -o ${@} ${<}

# build the lib with the same compile options
lib: ${BIN_DIRS} ${LIB_DIR} ${LIBOBJECTS}
	ar rcs $(call FIXPATH,${PROJECT_DIR}/${LIB_DIR}/${PROJECT}.a) ${LIBOBJECTS}
	@echo Libs created

# include the dependencies
-include ${DEPFILES}

# on linux it confuses the create directory target with dependency files
$(call FIXPATH,${PROJECT_DIR}/${OBJ_O_DIR})%.d:
	@echo -n ""

$(call FIXPATH,${PROJECT_DIR}/${OBJ_O_DIR})%:
	$(call makeDir,$(call FIXPATH,${@}))

${LIB_DIR}:
	$(call makeDir,$(call FIXPATH,${PROJECT_DIR}/${LIB_DIR}))

clean:
	$(shell ${RMDIR} ${OBJ_O_DIR} $(call FIXPATH,${PROJECT_DIR}/${LIB_DIR}))
	$(shell ${RM} ${PROJECT}${EXE})

# builds and runs the program
run: ${BIN_DIRS} ${PROJECT}
	./${PROJECT}${EXE}

# makes a dir for the given path
makeDir=$(shell ${MD} $(call FIXPATH,$1))
# make bin directories 
# makeBinDir=$(foreach dir,${BIN_DIRS},$(call makeDir,${dir}))

info:
	@echo Project Directory: ${PROJECT_DIR}
	@echo Source Directories: ${SOURCEDIRS} 
	@echo Lib Source Directories: ${LIBSOURCEDIRS} 
	@echo temp: ${COMPILE_OPTIONS} ${INCLUDES}
	@echo Object Files: ${OBJECTS}
	@echo Dependencies: ${DEPFILES}
