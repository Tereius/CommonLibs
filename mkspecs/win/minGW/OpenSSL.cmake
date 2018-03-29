include(ExternalProject)

set(OpenSSL_BRANCH OpenSSL_1_0_1-stable CACHE STRING "The git branch to use.")
set(OpenSSL_SHARED on CACHE BOOL "Bulid shared libs.")
set(OpenSSL_OPTIONS "" CACHE STRING "OpenSSL options forwarded to configure.")

if(EXTERNAL_PROJECT_IS_DEBUG)
    set(OPENSSL_COMPILER_CONFIG "mingw64 shared")
else()
    set(OPENSSL_COMPILER_CONFIG "mingw64 shared")
endif()

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/OpenSSL\"
perl Configure ${OPENSSL_COMPILER_CONFIG} ${OpenSSL_OPTIONS} --prefix=\"${EXTERNAL_PROJECT_INSTALL_DIR}\"
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/OpenSSL\"
make
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/OpenSSL\"
make install
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.sh
"
#!/bin/bash
cp \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libssl.a\" \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/ssl.a\"
cp \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libcrypto.a\" \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib/crypto.a\"
exit 0
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS zlib
    PREFIX ${EXTERNAL_PROJECT_NAME}
    STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://github.com/openssl/openssl.git
    GIT_TAG ${OpenSSL_BRANCH}
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

ExternalProject_Add_Step(${EXTERNAL_PROJECT_NAME} duplicatingLib
COMMAND bash ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.sh
COMMENT "Duplcating lib for common names."
DEPENDEES install
LOG 1
)
    