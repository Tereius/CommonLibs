include(ExternalProject)

set(X264_BRANCH stable CACHE STRING "The git branch to use.")
set(X264_OPTIONS "" CACHE STRING "x264 options forwarded to configure.")
set(X264_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")

if(X264_BUILD_SHARED)
	set(X264_OPTIONS "${X264_OPTIONS} --enable-shared")
endif(X264_BUILD_SHARED)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/x264-build\"
\"${EXTERNAL_PROJECT_BINARY_DIR}/src/x264/configure\" ${X264_OPTIONS} --prefix=\"${EXTERNAL_PROJECT_INSTALL_DIR}\"
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/x264-build\"
make
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/x264-build\"
make install
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
	PREFIX ${EXTERNAL_PROJECT_NAME}
	STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://git.videolan.org/git/x264.git
    GIT_TAG ${X264_BRANCH}
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

string(REPLACE "/" "\\" x264_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libx264.dll.lib")
string(REPLACE "/" "\\" x264_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libx264.lib")
file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.sh
"
#!/bin/bash
cp -f \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libx264.dll.a\" \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libx264.a\"
exit 0
"
)

ExternalProject_Add_Step(${EXTERNAL_PROJECT_NAME} duplicatingLib
    COMMAND bash ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.sh
    COMMENT "Duplcating lib for common names."
    DEPENDEES install
    LOG 1
)

set(EXTERNAL_PROJECT_PKG_CONFIG_PATH ${EXTERNAL_PROJECT_INSTALL_DIR}/lib/pkgconfig)
