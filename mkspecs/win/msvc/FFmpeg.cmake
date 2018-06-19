include(ExternalProject)

find_program(MSYS_EXECUTABLE msys2 DOC "msys2.exe")
get_filename_component(MSYS_DIR ${MSYS_EXECUTABLE} DIRECTORY)
set(MSYS_SHELL "${MSYS_DIR}/msys2_shell.cmd")

set(FFMPEG_BRANCH release/3.4 CACHE STRING "The git branch to use.")
set(FFMPEG_OPTIONS "--enable-openssl --enable-libx264 --enable-gpl --enable-nonfree" CACHE STRING "FFmpeg options forwarded to configure.")
set(FFMPEG_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")

if(FFMPEG_BUILD_SHARED)
	set(FFMPEG_OPTIONS "${FFMPEG_OPTIONS} --enable-shared")
endif(FFMPEG_BUILD_SHARED)

if(MSVC)
	set(FFMPEG_OPTIONS "${FFMPEG_OPTIONS} --toolchain=msvc")
endif(MSVC)

if(EXTERNAL_PROJECT_IS_DEBUG)
	set(FFMPEG_OPTIONS "${FFMPEG_OPTIONS} --disable-optimizations --disable-stripping") # broken
else()
	set(FFMPEG_OPTIONS "${FFMPEG_OPTIONS} --disable-debug") # broken
endif()

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/FFmpeg-build\"
call \"${MSYS_SHELL}\" -msys2 -defterm -no-start -use-full-path -here -c \"'${EXTERNAL_PROJECT_BINARY_DIR}/src/FFmpeg/configure' --extra-cflags='-DWIN32_LEAN_AND_MEAN' ${FFMPEG_OPTIONS} --prefix='${EXTERNAL_PROJECT_INSTALL_DIR}'\"
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/FFmpeg-build\"
call \"${MSYS_SHELL}\" -msys2 -defterm -no-start -use-full-path -here -c \"make\"
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/FFmpeg-build\"
call \"${MSYS_SHELL}\" -msys2 -defterm -no-start -use-full-path -here -c \"make install\"
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
	DEPENDS nasm zlib x264 OpenSSL
	PREFIX ${EXTERNAL_PROJECT_NAME}
	STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    GIT_TAG ${FFMPEG_BRANCH}
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
