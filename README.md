
	
	Author : Abdullah Aldokhi
	Github: https://github.com/codes-abdullah
 	(Tested on Linux systems)
	
	While learning C++, I struggled with:
	- Adding libraries manually to Eclipse CDT, which is nightmare.
	- Eclipse CDT does not generate Makefile with new projects.
	- I’ve been spoiled by Java and it’s tools for long time, debugging was a click, never thought
	 that debugging in C++ requires different flags, which means different binary, which means
	different launch location to make IDE's such as Eclipse CDT and Code::Blocks able to debug the app interactively.
	- In Java, we had packages which organized our projects in a fancy way, in C++, most of the
	source projects I’ve seen used one single directory for all source files, and probably another
	far-away directory for header files (in project), so source nested files/dirs are not common in C++.
	
	As Java spoiled and well organized developer, I could not like my projects to be missy
	which force me to learn gnu-make which I was never ever wanted to work with, hoa!!
	
	
	So I spent sometime learning the basics of gnu-make and cameup with this script file.
	This file has full support for 2 modes to resolve all mentioned cons above:
	
	- Declare a variable named NO_IDE with value of ‘run’ or ‘debug’ for regular projects on any
	text editor application (remove single quotes in values)
	- Declare a variable named IDE with value of ‘ECLIPSE’ or ‘CODE_BLOCKS’ for Eclipse
	CDT or Code::Blocks projects accordingly (remove single quotes in values)
	- You can’t have both to be declared (IDE and NO_IDE)
	

	Futures:
	- Supports any nested source files/header files within main ‘src’ directory.
	- Supports one ‘include’ directory next to ‘src’ directory, so any header files located in the
	‘include’ directory will be including during compile time (old-school method).
	- Libraries can be added by mentioning their names located in pkg-config, e.g: ‘glew’ library
	named ‘glew’ with –cflags: -lGLEW -lGLU -lGL and –libs: -lGLEW -lGLU -lGL,
	and ‘glfw’ named ‘glfw3’ with no –cflags and with –libs: -lglfw
	modify the variable ‘INCLUDE_LIBRARY’, e.g: INCLUDE_LIBRARY := glfw3 glew
	- Flags for Release mode can be used in ‘CXXFLAGS_BUILD’, and for debug
	‘CXXFLAGS_DEBUG’

	Targets:
	- [all]: The main and first (default) build target, for IDE = ECLIPSE or NO_IDE = run/debug, this can be used by default for building
	- [clean]: the main clean target, for IDE = ECLIPSE or NO_IDE = run/debug, this can be used by default, 
	the clean target is build-context based, e.g if NO_IDE = debug, clean target will clean debug directory only,
	also, if IDE = ECLIPSE and BUILD_MODE = run, will clean build/default directory only
	and for IDE = CODE_BLOCKS, and MAKECMDGOALS = cleanRelease, will clean bin/Release and obj/Release only
	- [Release]: Is a special target for IDE = CODE_BLOCKS mode, it will build the project in bin/Release and obj/Release
	- [Debug]: Is a special target for IDE = CODE_BLOCKS mode, it will build the project in bin/Debug and obj/Debug
	- [cleanRelease]: Is a special target for IDE = CODE_BLOCKS mode, it will clean bin/Release and Obj/release
	- [cleanDebug]: Is a special target for IDE = CODE_BLOCKS mode, it will clean bin/Debug and obj/Debug
	- [cleanAll]: This target will clean all known builds, such as: build/ directory for ECLIPSE and NO_IDE,
	and bin/ and obj/ dirs for CODE_BLOCKS
	- [createRunScript]: Create bash script named run/debug (build context based) to run application, the output of the
	run/debug script is the project root dir, invoking this target requires sudo password to setup permissions
	- [createBuildAndRunScript]: Create bash script named run/debug (build context based) to build and run application.
	- [check]: internal usage
	- [test]: internal usage
	-
	-

	Bugs and cons:
	- For NO_IDE and for IDE=ECLIPSE, this script supports multi target execution at once, 
	e.g: make clean all
	but for IDE=CODE_BLOCKS mode, only single target is supported
	- The script will compile every single source file individually, that comes as tread-off with
	nested source directories, so this is a ver slow process, 
	it is highly recommended to run make with parallel flag -j, e.g: ‘make -j all’, will try in future to
	add an option for single source directory like old-school method


