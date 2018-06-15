include(ExternalProject)

set(Qt5_BRANCH 5.9 CACHE STRING "The git branch to use.")
set(Qt5_OPTIONS "-opensource -confirm-license -nomake examples -nomake tests -openssl-linked" CACHE STRING "Qt5 options forwarded to configure.")
set(Qt5_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")
set(Qt5_MODULES "qtbase qtsvg qtdeclarative qttools qttranslations qtrepotools qtqa qtgraphicaleffects qtquickcontrols qtquickcontrols2" CACHE STRING "QT Submodules.")

if(Qt5_BUILD_SHARED)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} -shared")
else(Qt5_BUILD_SHARED)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} OPENSSL_LIBS=\"-lssl -lcrypto -L${OpenSSL_EXTERNAL_LIB_PATH}\" -static -L ${OpenSSL_EXTERNAL_LIB_PATH} -I ${OpenSSL_EXTERNAL_INCLUDE_PATH} -L ${zlib_EXTERNAL_LIB_PATH} -I ${zlib_EXTERNAL_INCLUDE_PATH}")
endif(Qt5_BUILD_SHARED)

if(EXTERNAL_PROJECT_IS_DEBUG)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} -no-debug-and-release -debug")
elseif(EXTERNAL_PROJECT_IS_RELEASE)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} -no-debug-and-release -release")
endif()

if(MSVC)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} -platform win32-msvc -mp")
endif(MSVC)

if(WIN32)

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
	"
	call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
	call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
	cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5-build\"
	call \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5/configure.bat\" ${Qt5_OPTIONS} -prefix \"${EXTERNAL_PROJECT_INSTALL_DIR}\"
	"
	)

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
	"
	call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
	call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
	cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5-build\"
	nmake
	"
	)

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
	"
	call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
	call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
	cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5-build\"
	nmake install
	"
	)

	ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
		DEPENDS Python Perl zlib OpenSSL
		PREFIX ${EXTERNAL_PROJECT_NAME}
		STAMP_DIR ${CMAKE_BINARY_DIR}/logs
		GIT_REPOSITORY https://code.qt.io/qt/qt5.git
		GIT_TAG ${Qt5_BRANCH}
		GIT_SUBMODULES ${Qt5_MODULES}
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
endif(WIN32)
