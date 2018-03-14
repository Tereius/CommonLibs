include(ExternalProject)

find_program(MSYS_EXECUTABLE msys2 DOC "msys2.exe")
get_filename_component(MSYS_DIR ${MSYS_EXECUTABLE} DIRECTORY)

set(OpenSSL_BRANCH OpenSSL_1_0_1-stable CACHE STRING "The git branch to use.")
set(OpenSSL_SHARED on CACHE BOOL "Bulid shared libs.")
set(OpenSSL_OPTIONS "" CACHE STRING "OpenSSL options forwarded to configure.")

if(WIN32)

	if(EXTERNAL_PROJECT_IS_DEBUG)
		set(OPENSSL_COMPILER_CONFIG "debug-VC-WIN64A")
	else()
		set(OPENSSL_COMPILER_CONFIG "VC-WIN64A")
	endif()

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
	"
	call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
	call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
	cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/OpenSSL\"
	perl Configure ${OPENSSL_COMPILER_CONFIG} ${OpenSSL_OPTIONS} --prefix=\"${EXTERNAL_PROJECT_INSTALL_DIR}\"
	call ms/do_win64a.bat
	"
	)

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
	"
	call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
	call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
	cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/OpenSSL\"
	nmake -f ms/ntdll.mak
	"
	)

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
	"
	call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
	call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
	cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/OpenSSL\"
	nmake -f ms/ntdll.mak install
	"
	)

	string(REPLACE "/" "\\" SSLEAY_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/ssleay32.lib")
	string(REPLACE "/" "\\" SSLEAY_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/ssl.lib")
	string(REPLACE "/" "\\" LIBEAY_FROM "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/libeay32.lib")
	string(REPLACE "/" "\\" LIBEAY_TO "${EXTERNAL_PROJECT_INSTALL_DIR}/lib/crypto.lib")
	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.bat
	"
	copy /Y \"${SSLEAY_FROM}\" \"${SSLEAY_TO}\"
	copy /Y \"${LIBEAY_FROM}\" \"${LIBEAY_TO}\"
	exit 0
	"
	)

	ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
		DEPENDS Perl zlib
		PREFIX ${EXTERNAL_PROJECT_PREFIX}
		STAMP_DIR ${CMAKE_BINARY_DIR}/logs
		GIT_REPOSITORY https://github.com/openssl/openssl.git
		GIT_TAG ${OpenSSL_BRANCH}
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
	
	ExternalProject_Add_Step(${EXTERNAL_PROJECT_NAME} duplicatingLib
	COMMAND ${EXTERNAL_PROJECT_BINARY_DIR}/duplicatingLib.bat
	COMMENT "Duplcating lib for common names."
	DEPENDEES install
	LOG 1
	)
endif(WIN32)
