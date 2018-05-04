include(ExternalProject)

find_program(MSYS_EXECUTABLE msys2 DOC "msys2.exe")
get_filename_component(MSYS_DIR ${MSYS_EXECUTABLE} DIRECTORY)
set(MSYS_SHELL "${MSYS_DIR}/msys2_shell.cmd")

set(X264_BRANCH stable CACHE STRING "The git branch to use.")
set(X264_OPTIONS "" CACHE STRING "x264 options forwarded to configure.")
set(X264_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")

if(X264_BUILD_SHARED)
	set(X264_OPTIONS "${X264_OPTIONS} --enable-shared")
endif(X264_BUILD_SHARED)

if(MSVC)
	set(X264_OPTIONS "${X264_OPTIONS} --extra-cflags=-DNO_PREFIX")
endif(MSVC)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/x264-build\"
call \"${MSYS_SHELL}\" -mingw64 -defterm -no-start -use-full-path -here -c \"CC=cl '${EXTERNAL_PROJECT_BINARY_DIR}/src/x264/configure' ${X264_OPTIONS} --prefix='${EXTERNAL_PROJECT_INSTALL_DIR}'\"
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/x264-build\"
call \"${MSYS_SHELL}\" -mingw64 -defterm -no-start -use-full-path -here -c \"make\"
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/x264-build\"
call \"${MSYS_SHELL}\" -mingw64 -defterm -no-start -use-full-path -here -c \"make install\"
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
	DEPENDS nasm
	PREFIX ${EXTERNAL_PROJECT_NAME}
	STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://git.videolan.org/git/x264.git
    GIT_TAG ${X264_BRANCH}
	CONFIGURE_COMMAND ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
	BUILD_COMMAND ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
	INSTALL_COMMAND ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
	LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
)

string(REPLACE "/" "\\" x264_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libx264.dll.lib")
string(REPLACE "/" "\\" x264_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libx264.lib")
file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.bat
"
copy /Y \"${x264_FROM}\" \"${x264_TO}\"
exit 0
"
)

ExternalProject_Add_Step(${EXTERNAL_PROJECT_NAME} duplicatingLib
    COMMAND ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.bat
    COMMENT "Duplcating lib for common names."
    DEPENDEES install
    LOG 1
)
