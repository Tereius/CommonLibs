include(ExternalProject)

set(Qt5_BRANCH v5.9.3 CACHE STRING "The git branch to use.")
set(Qt5_OPTIONS "-opensource -confirm-license -nomake examples -nomake tests -ssl -openssl-linked" CACHE STRING "Qt5 options forwarded to configure.")
set(Qt5_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")
set(Qt5_MODULES "qtbase qtsvg qtdeclarative qttools qttranslations qtrepotools qtqa qtgraphicaleffects qtquickcontrols qtquickcontrols2" CACHE STRING "QT Submodules.")

if(Qt5_BUILD_SHARED)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} -shared")
else(Qt5_BUILD_SHARED)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} -static")
endif(Qt5_BUILD_SHARED)

if(EXTERNAL_PROJECT_IS_DEBUG)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} -no-debug-and-release -debug")
elseif(EXTERNAL_PROJECT_IS_RELEASE)
	set(Qt5_OPTIONS "${Qt5_OPTIONS} -no-debug-and-release -release")
endif()

set(Qt5_OPTIONS "${Qt5_OPTIONS} -platform win32-g++")

if(WIN32)

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.sh
    "
    #!/bin/bash
	source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
	cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5-build\"
	\"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5/configure\" ${Qt5_OPTIONS} -prefix \"${EXTERNAL_PROJECT_INSTALL_DIR}\"
	"
	)

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.sh
    "
    #!/bin/bash
	source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
	cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5-build\"
	make
	"
	)

	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.sh
    "
    #!/bin/bash
	source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
	cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5-build\"
	make install
	"
	)

	ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
		DEPENDS zlib OpenSSL
		PREFIX ${EXTERNAL_PROJECT_NAME}
		STAMP_DIR ${CMAKE_BINARY_DIR}/logs
		GIT_REPOSITORY https://code.qt.io/qt/qt5.git
		GIT_TAG ${Qt5_BRANCH}
		GIT_SUBMODULES ${Qt5_MODULES}
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
endif(WIN32)
