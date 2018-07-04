include(ExternalProject)

set(Qt5_BRANCH 5.9 CACHE STRING "The git branch to use.")
set(Qt5_OPTIONS "-opensource -confirm-license -nomake examples -nomake tests -openssl-linked" CACHE STRING "Qt5 options forwarded to configure.")
set(Qt5_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")
set(Qt5_MODULES "qtbase qtsvg qtdeclarative qttools qttranslations qtrepotools qtqa qtgraphicaleffects qtquickcontrols qtquickcontrols2" CACHE STRING "QT Submodules.")
set(Qt5_MOVABLE on CACHE BOOL "Put qt.conf in install dir to overwrite hardcoded QT_INSTALL_PREFIX so the install dir can be moved.")

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

	string(REPLACE ";" " -I" EXTERNAL_INCLUDE_PATH_STR_ "${EXTERNAL_INCLUDE_PATH}")
	string(REPLACE ";" " -L" EXTERNAL_LIB_PATH_STR_ "${EXTERNAL_LIB_PATH}")
	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.sh
    "
    #!/bin/bash
	source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
	cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5-build\"
	\"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5/configure\" ${Qt5_OPTIONS} ${EXTERNAL_INCLUDE_PATH_STR_} ${EXTERNAL_LIB_PATH_STR_} -prefix \"${EXTERNAL_PROJECT_INSTALL_DIR}\"
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

	string(REPLACE "/" "\\" EXTERNAL_PROJECT_INSTALL_DIR_BACK "${EXTERNAL_PROJECT_INSTALL_DIR}")
	file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.sh
    "
    #!/bin/bash
	source \"${CMAKE_BINARY_DIR}/setSearchEnv.sh\"
	cd \"${EXTERNAL_PROJECT_BINARY_DIR}/src/Qt5-build\"
	make install
	cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}\"
	IF EXIST \"qt.conf\" (
		copy qt.conf \"${EXTERNAL_PROJECT_INSTALL_DIR_BACK}\\bin\"
	)
	"
	)

	if(Qt5_MOVABLE)
		file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/qt.conf
		"
		[Paths]
		Prefix=..
		"
		)
	endif()

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
