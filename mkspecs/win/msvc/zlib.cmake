include(ExternalProject)

set(ZLIB_BRANCH v1.2.11 CACHE STRING "The git branch to use.")
set(ZLIB_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/zlib-build\"
\"${CMAKE_COMMAND}\" -G \"${CMAKE_GENERATOR}\" -DCMAKE_INSTALL_PREFIX:PATH=${EXTERNAL_PROJECT_INSTALL_DIR} -DCMAKE_PREFIX_PATH:PATH=${EXTERNAL_CMAKE_PREFIX_PATH} -DCMAKE_CONFIGURATION_TYPES:STRING=${CMAKE_CONFIGURATION_TYPES} -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE} ${EXTERNAL_PROJECT_BINARY_DIR}/src/zlib 
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
\"${CMAKE_COMMAND}\" --build ${EXTERNAL_PROJECT_BINARY_DIR}/src/zlib-build --config ${EXTERNAL_PROJECT_BUILD_TYPE}
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
\"${CMAKE_COMMAND}\" --build ${EXTERNAL_PROJECT_BINARY_DIR}/src/zlib-build --config ${EXTERNAL_PROJECT_BUILD_TYPE} --target install
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    PREFIX ${EXTERNAL_PROJECT_NAME}
    STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://github.com/madler/zlib
    GIT_TAG ${ZLIB_BRANCH}
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

if(ZLIB_BUILD_SHARED)
    string(REPLACE "/" "\\" ZLIB_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlib.lib")
    string(REPLACE "/" "\\" ZLIB_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zdll.lib")
    string(REPLACE "/" "\\" ZLIBD_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlibd.lib")
    string(REPLACE "/" "\\" ZLIBD_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zdll.lib")
    string(REPLACE "/" "\\" ZLIBD2_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlibd.lib")
    string(REPLACE "/" "\\" ZLIBD2_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlib.lib")
else()
    string(REPLACE "/" "\\" ZLIB_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlibstatic.lib")
    string(REPLACE "/" "\\" ZLIB_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zdll.lib")
    string(REPLACE "/" "\\" ZLIBD_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlibstaticd.lib")
    string(REPLACE "/" "\\" ZLIBD_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zdll.lib")
    string(REPLACE "/" "\\" ZLIBD2_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlibstatic.lib")
    string(REPLACE "/" "\\" ZLIBD2_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlib.lib")
    string(REPLACE "/" "\\" ZLIBD3_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlibstaticd.lib")
    string(REPLACE "/" "\\" ZLIBD3_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/zlib.lib")
endif()

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.bat
"
copy /Y \"${ZLIB_FROM}\" \"${ZLIB_TO}\"
copy /Y \"${ZLIBD_FROM}\" \"${ZLIBD_TO}\"
copy /Y \"${ZLIBD2_FROM}\" \"${ZLIBD2_TO}\"
copy /Y \"${ZLIBD3_FROM}\" \"${ZLIBD3_TO}\"
exit 0
"
)

ExternalProject_Add_Step(${EXTERNAL_PROJECT_NAME} duplicatingLib
    COMMAND ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.bat
    COMMENT "Duplcating lib for common names."
    DEPENDEES install
    LOG 1
)
