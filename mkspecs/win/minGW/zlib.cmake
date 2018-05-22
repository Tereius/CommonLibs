include(ExternalProject)

set(ZLIB_BRANCH v1.2.11 CACHE STRING "The git branch to use.")

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/zlib-build\"
\"${CMAKE_COMMAND}\" -G \"${CMAKE_GENERATOR}\" -DCMAKE_INSTALL_PREFIX:PATH=${EXTERNAL_PROJECT_INSTALL_DIR} -DCMAKE_PREFIX_PATH:PATH=${EXTERNAL_CMAKE_PREFIX_PATH} -DCMAKE_CONFIGURATION_TYPES:STRING=${CMAKE_CONFIGURATION_TYPES} -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE} ${EXTERNAL_PROJECT_BINARY_DIR}/src/zlib 
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
\"${CMAKE_COMMAND}\" --build ${EXTERNAL_PROJECT_BINARY_DIR}/src/zlib-build --config ${EXTERNAL_PROJECT_BUILD_TYPE}
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
\"${CMAKE_COMMAND}\" --build ${EXTERNAL_PROJECT_BINARY_DIR}/src/zlib-build --config ${EXTERNAL_PROJECT_BUILD_TYPE} --target install
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    PREFIX ${EXTERNAL_PROJECT_NAME}
    STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://github.com/madler/zlib
    GIT_TAG ${ZLIB_BRANCH}
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

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.sh
"
#!/bin/bash
cp \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libzlib.dll.a\" \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zdll.a\"
cp \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libzlibd.dll.a\" \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zdll.a\"
cp \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libzlibd.dll.a\" \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlib.a\"´
cp \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libzlib.dll.a\" \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlib.a\"
exit 0
"
)

ExternalProject_Add_Step(${EXTERNAL_PROJECT_NAME} duplicatingLib
    COMMAND bash ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.sh
    COMMENT "Duplcating lib for common names."
    DEPENDEES install
    LOG 1
)

set(EXTERNAL_PROJECT_PKG_CONFIG_PATH ${EXTERNAL_PROJECT_INSTALL_DIR}/share/pkgconfig)
