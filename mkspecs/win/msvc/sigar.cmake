include(ExternalProject)

set(SIGAR_BRANCH master CACHE STRING "The git branch to use.")

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/sigar\"
call git apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/sigar.patch 2>&1
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/sigar-build\"
\"${CMAKE_COMMAND}\" -G \"${CMAKE_GENERATOR}\" -DCMAKE_INSTALL_PREFIX:PATH=${EXTERNAL_PROJECT_INSTALL_DIR} -DCMAKE_PREFIX_PATH:PATH=${EXTERNAL_CMAKE_PREFIX_PATH} -DCMAKE_CONFIGURATION_TYPES:STRING=${CMAKE_CONFIGURATION_TYPES} -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE} ${EXTERNAL_PROJECT_BINARY_DIR}/src/sigar 
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
\"${CMAKE_COMMAND}\" --build ${EXTERNAL_PROJECT_BINARY_DIR}/src/sigar-build --config ${EXTERNAL_PROJECT_BUILD_TYPE}
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
\"${CMAKE_COMMAND}\" --build ${EXTERNAL_PROJECT_BINARY_DIR}/src/sigar-build --config ${EXTERNAL_PROJECT_BUILD_TYPE} --target install
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    PREFIX ${EXTERNAL_PROJECT_NAME}
    STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://github.com/rob100/sigar.git
    GIT_TAG ${SIGAR_BRANCH}
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
