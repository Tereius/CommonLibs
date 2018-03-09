include(ExternalProject)

set(QtAv_BRANCH master CACHE STRING "The git branch to use.")

string(REPLACE ";" " -L" EXTERNAL_LIB_PATH_STRING "${EXTERNAL_LIB_PATH}")
string(REPLACE ";" " " EXTERNAL_INCLUDE_PATH_STRING "${EXTERNAL_INCLUDE_PATH}")
file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV\"
qmake -r -tp vc \"LIBS+=${EXTERNAL_LIB_PATH_STRING}\" \"INCLUDEPATH+=${EXTERNAL_INCLUDE_PATH_STRING}\" QtAV.pro
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV\"
msbuild /p:Configuration=${EXTERNAL_PROJECT_BUILD_TYPE}
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/lib_win_x86_64/*Qt*AV*.lib*\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/lib_win_x86_64/QtAV1.lib\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/lib_win_x86_64/QtAVd1.lib\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/bin/Qt*AV*.dll\"
REM 
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/lib_win_x86_64/*Qt*AV*.lib*\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/lib_win_x86_64/QtAVWidgets1.lib\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/lib_win_x86_64/QtAVWidgetsd1.lib\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/bin/Qt*AV*.dll\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/src/QtAV/*.h\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/src/QtAV/QtAV\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/widgets/QtAVWidgets/*.h\"
REM copy /y \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtAV/widgets/QtAVWidgets/QtAVWidgets\"
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS FFmpeg Qt5
	PREFIX ${EXTERNAL_PROJECT_PREFIX}
    GIT_REPOSITORY https://github.com/wang-bin/QtAV.git
    GIT_TAG ${QtAv_BRANCH}
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
