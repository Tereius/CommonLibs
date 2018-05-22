include(ExternalProject)

set(FFMPEG_BRANCH release/3.4 CACHE STRING "The git branch to use.")
set(FFMPEG_OPTIONS "--enable-openssl --enable-libx264 --enable-gpl --enable-nonfree" CACHE STRING "FFmpeg options forwarded to configure.")
set(FFMPEG_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")

if(FFMPEG_BUILD_SHARED)
	set(FFMPEG_OPTIONS "${FFMPEG_OPTIONS} --enable-shared")
endif(FFMPEG_BUILD_SHARED)

if(EXTERNAL_PROJECT_IS_DEBUG)
	set(FFMPEG_OPTIONS "${FFMPEG_OPTIONS} --disable-optimizations --disable-stripping") # broken
else()
	set(FFMPEG_OPTIONS "${FFMPEG_OPTIONS} --disable-debug") # broken
endif()

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/FFmpeg-build\"
\"${EXTERNAL_PROJECT_BINARY_DIR}/src/FFmpeg/configure\" --extra-cflags=\"-DWIN32_LEAN_AND_MEAN\" ${FFMPEG_OPTIONS} --prefix=\"${EXTERNAL_PROJECT_INSTALL_DIR}\"
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/FFmpeg-build\"
make
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/FFmpeg-build\"
make install
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
	DEPENDS zlib x264 OpenSSL
	PREFIX ${EXTERNAL_PROJECT_NAME}
	STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    GIT_TAG ${FFMPEG_BRANCH}
	CONFIGURE_COMMAND bash ${EXTERNAL_PROJECT_BINARY_DIR}/configure.sh
	BUILD_COMMAND bash ${EXTERNAL_PROJECT_BINARY_DIR}/build.sh
	INSTALL_COMMAND bash ${EXTERNAL_PROJECT_BINARY_DIR}/install.sh
	LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
)

set(EXTERNAL_PROJECT_PKG_CONFIG_PATH ${EXTERNAL_PROJECT_INSTALL_DIR}/lib/pkgconfig)
