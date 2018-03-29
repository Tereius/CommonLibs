include(ExternalProject)

set(gsoap_REVISION "130" CACHE STRING "The svn revision to use.")
set(gsoap_OPTIONS "--with-zlib='${zlib_EXTERNAL_PATH}' --with-openssl='${OpenSSL_EXTERNAL_PATH}'" CACHE STRING "gsoap options forwarded to configure." FORCE)

if(EXTERNAL_PROJECT_IS_DEBUG)
	#set(gsoap_OPTIONS "${gsoap_OPTIONS} --enable-debug")
endif()

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/gsoap\"
make distclean
autoreconf -f -i
make distclean
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/gsoap-build\"
bash \"${EXTERNAL_PROJECT_BINARY_DIR}/src/gsoap/configure\" ${gsoap_OPTIONS} --prefix='${EXTERNAL_PROJECT_INSTALL_DIR}'
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/gsoap-build\"
make
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.sh
"
#!/bin/bash
source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/gsoap-build\"
make install
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
	DEPENDS zlib OpenSSL
	PREFIX ${EXTERNAL_PROJECT_NAME}
	STAMP_DIR ${CMAKE_BINARY_DIR}/logs
	SVN_REPOSITORY https://svn.code.sf.net/p/gsoap2/code
	SVN_REVISION -r ${gsoap_REVISION}
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
