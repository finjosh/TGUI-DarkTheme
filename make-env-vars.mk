#* ALL paths should start with a / and end without one
#* Try to use COMPILE_OS instead of HOST_OS unless needed
# Some variables that are accessible at eval
# HOST_OS: the OS the makefile is running on
# COMPILE_OS: the OS the code is being compiled for
# PROJECT_DIRECTORY: the directory where the makefile is being run from
# MOUNT_POINT: the mount point of the filesystem
# BUILD_RELEASE: the type of release (debug or release)
# BUILD_TYPE: the type of build (debug or release)

#* The following will be evaluated in the order they are listed, if applicable
#* i.e. executable_config is evaluated after general_config if compiling an executable
#* First, general_config, then BUILT_TYPE, then BUILD_RELEASE, then OS

define general_config
	MAKEFLAGS:=-j$$(NUM_THREADS)
	
	PROJECT_NAME:=dark-light-theme
	# empty defaults to ${PROJECT_DIRECTORY}
	PROJECT_OUT_DIRECTORY:=
	OBJECT_OUT_DIRECTORY:=/bin/$${COMPILE_OS}
	LINKER_FLAGS:=SET_LATER
	INCLUDE_FLAGS:=
	EXECUTABLE_EXTENSION:=SET_LATER
	LIB_EXTENSION:=SET_LATER
	
	CPP_COMPILER:=g++
	C_COMPILER:=gcc
	CREATE_LIB:=SET_LATER

	CPP_COMPILER_FLAGS:=-std=c++20
	C_COMPILER_FLAGS:=-std=c17
	# any other compiler options for both C and CPP (warning flags -Wextra -Wall)
	C_CPP_COMPILER_FLAGS:=
	PROJECT_FINAL_FLAGS:=
	
	# Where the source files will be found (recursive)
	SOURCE_DIRECTORIES:=/src
	# Where you don't want underlying folders to be included
	# Leave empty for no non-recursive directories
	# just use . for the project directory
	NON_RECURSIVE_SOURCE_DIRECTORIES:=.

	# Not required to be defined, but are useful for my environment
	LIBRARY_PREFIX:=$${MOUNT_POINT}/dev-env/libraries/$${COMPILE_OS}
	GIT_LIB_PREFIX:=$$(MOUNT_POINT)/dev-env/git-projects
	# -------------------------------------------------------------

	INCLUDE_DIRECTORIES=$${LIBRARY_PREFIX}/SFML-3.0.0/include $${LIBRARY_PREFIX}/TGUI-1.9.0/include\
								$${PROJECT_DIRECTORY} $${PROJECT_DIRECTORY}/include
	LIB_DIRECTORIES=$${LIBRARY_PREFIX}/SFML-3.0.0/lib $${LIBRARY_PREFIX}/TGUI-1.9.0/lib
endef

define executable_config
	PROJECT_NAME:=main
endef

define lib_config
	PROJECT_NAME:=dark-light-theme
	PROJECT_OUT_DIRECTORY:=/lib/$${COMPILE_OS}
	NON_RECURSIVE_SOURCE_DIRECTORIES:=
endef

define debug_config
	ifeq ($${BUILD_TYPE},library)
	PROJECT_NAME:=$${PROJECT_NAME}-d
	endif

	C_CPP_COMPILER_FLAGS:=${C_CPP_COMPILER_FLAGS} -g -DDEBUG
	OBJECT_OUT_DIRECTORY:=${OBJECT_OUT_DIRECTORY}/debug
endef

define release_config
	C_CPP_COMPILER_FLAGS:=${C_CPP_COMPILER_FLAGS} -O3
	OBJECT_OUT_DIRECTORY:=${OBJECT_OUT_DIRECTORY}/release
endef

define windows_config
	EXECUTABLE_EXTENSION:=.exe
	LIB_EXTENSION:=.a
	CREATE_LIB:=ar rcs

	C_CPP_COMPILER_FLAGS:=${C_CPP_COMPILER_FLAGS} -static
	INCLUDE_FLAGS:=-D SFML_STATIC
	LINKER_FLAGS:=-ltgui-s \
				  -lsfml-graphics-s -lsfml-window-s -lsfml-system-s -lopengl32 -lfreetype \
				  -lsfml-window-s -lsfml-system-s -lopengl32 -lwinmm -lgdi32 \
				  -lsfml-audio-s -lsfml-system-s -lFLAC -lvorbisenc -lvorbisfile -lvorbis -logg \
				  -lsfml-network-s -lsfml-system-s -lws2_32 \
				  -lsfml-system-s -lwinmm \
				  -lstdc++
endef

# First windows_config is evaluated, then windows_via_linux_config
define windows_via_linux_config
	CPP_COMPILER:=x86_64-w64-mingw32-g++
	C_COMPILER:=x86_64-w64-mingw32-gcc
	CREATE_LIB:=x86_64-w64-mingw32-ar rcs
endef

define linux_config
	EXECUTABLE_EXTENSION:=
	LIB_EXTENSION:=.so
	CREATE_LIB:=g++ -shared -o
	
	INCLUDE_DIRECTORIES:=$${INCLUDE_DIRECTORIES} /usr/include
	LIB_DIRECTORIES:=$${LIB_DIRECTORIES} /lib
	# LIBS_SEARCH_PATHS is where the program will look for the shared libraries at runtime
	# LIB_DIRECTORIES is added here for simple testing
	LIBS_SEARCH_PATHS:=./ ./lib \
						$${LIB_DIRECTORIES}
	LINKER_FLAGS:=-ltgui \
					-lsfml-graphics -lsfml-window -lsfml-system \
					-lsfml-window -lsfml-system \
					-lsfml-audio -lsfml-system \
					-lsfml-network \
					-lsfml-system \
					-lstdc++ $$(patsubst %,-Wl$${COMMA}-rpath$${COMMA}%,$${LIBS_SEARCH_PATHS})

	C_CPP_COMPILER_FLAGS:=$${C_CPP_COMPILER_FLAGS} -fPIC
endef