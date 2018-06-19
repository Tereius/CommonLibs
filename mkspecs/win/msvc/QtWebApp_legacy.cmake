include(ExternalProject)

set(QtWebApp_legacy_BRANCH master CACHE STRING "The git branch to use.")
set(QtWebApp_legacy_BUILD_SHARED on CACHE BOOL "Bulid shared libs.")

if(QtWebApp_legacy_BUILD_SHARED)
    set(QtWebApp_legacy_OPTIONS "")
else()
    set(QtWebApp_legacy_OPTIONS "CONFIG+=staticlib")
endif()

string(REPLACE ";" " -L" EXTERNAL_LIB_PATH_STRING "${EXTERNAL_LIB_PATH}")
string(REPLACE ";" " " EXTERNAL_INCLUDE_PATH_STRING "${EXTERNAL_INCLUDE_PATH}")
file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/configure.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtWebApp_legacy/QtWebApp/\"
qmake -r -tp vc ${QtWebApp_legacy_OPTIONS} \"LIBS+=${EXTERNAL_LIB_PATH_STRING}\" \"INCLUDEPATH+=${EXTERNAL_INCLUDE_PATH_STRING}\" QtWebApp.pro
"
)

file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/build.bat
"
call \"${CMAKE_BINARY_DIR}/setMsvcEnv.bat\"
call \"${CMAKE_BINARY_DIR}/setSearchEnv.bat\"
cd /D \"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtWebApp_legacy/QtWebApp/\"
msbuild /p:Configuration=${EXTERNAL_PROJECT_BUILD_TYPE} /p:OutDir=\"${EXTERNAL_PROJECT_BINARY_DIR}/src/QtWebApp_legacy-build\"
"
)

string(REPLACE "/" "\\" EXTERNAL_PROJECT_BINARY_DIR_BACK "${EXTERNAL_PROJECT_BINARY_DIR}")
string(REPLACE "/" "\\" EXTERNAL_PROJECT_INSTALL_DIR_BACK "${EXTERNAL_PROJECT_INSTALL_DIR}")
file(WRITE ${EXTERNAL_PROJECT_BINARY_DIR}/install.bat
"
\"${CMAKE_COMMAND}\" -E make_directory \"${EXTERNAL_PROJECT_INSTALL_DIR}\"
\"${CMAKE_COMMAND}\" -E make_directory \"${EXTERNAL_PROJECT_INSTALL_DIR}/bin\"
\"${CMAKE_COMMAND}\" -E make_directory \"${EXTERNAL_PROJECT_INSTALL_DIR}/lib\"
\"${CMAKE_COMMAND}\" -E make_directory \"${EXTERNAL_PROJECT_INSTALL_DIR}/include\"
\"${CMAKE_COMMAND}\" -E make_directory \"${EXTERNAL_PROJECT_INSTALL_DIR}/include/httpserver\"
\"${CMAKE_COMMAND}\" -E make_directory \"${EXTERNAL_PROJECT_INSTALL_DIR}/include/logging\"
\"${CMAKE_COMMAND}\" -E make_directory \"${EXTERNAL_PROJECT_INSTALL_DIR}/include/qtservice\"
\"${CMAKE_COMMAND}\" -E make_directory \"${EXTERNAL_PROJECT_INSTALL_DIR}/include/templateengine\"
copy /Y \"${EXTERNAL_PROJECT_BINARY_DIR_BACK}\\src\\QtWebApp_legacy-build\\*.lib\" \"${EXTERNAL_PROJECT_INSTALL_DIR_BACK}\\lib\"
copy /Y \"${EXTERNAL_PROJECT_BINARY_DIR_BACK}\\src\\QtWebApp_legacy-build\\*.dll\" \"${EXTERNAL_PROJECT_INSTALL_DIR_BACK}\\bin\"
copy /Y \"${EXTERNAL_PROJECT_BINARY_DIR_BACK}\\src\\QtWebApp_legacy\\QtWebApp\\httpserver\\*.h\" \"${EXTERNAL_PROJECT_INSTALL_DIR_BACK}\\include\\httpserver\"
copy /Y \"${EXTERNAL_PROJECT_BINARY_DIR_BACK}\\src\\QtWebApp_legacy\\QtWebApp\\logging\\*.h\" \"${EXTERNAL_PROJECT_INSTALL_DIR_BACK}\\include\\logging\"
copy /Y \"${EXTERNAL_PROJECT_BINARY_DIR_BACK}\\src\\QtWebApp_legacy\\QtWebApp\\qtservice\\*.h\" \"${EXTERNAL_PROJECT_INSTALL_DIR_BACK}\\include\\qtservice\"
copy /Y \"${EXTERNAL_PROJECT_BINARY_DIR_BACK}\\src\\QtWebApp_legacy\\QtWebApp\\templateengine\\*.h\" \"${EXTERNAL_PROJECT_INSTALL_DIR_BACK}\\include\\templateengine\"
"
)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS Qt5
    PREFIX ${EXTERNAL_PROJECT_NAME}
    STAMP_DIR ${CMAKE_BINARY_DIR}/logs
    GIT_REPOSITORY https://github.com/fffaraz/QtWebApp.git
    GIT_TAG ${QtWebApp_legacy_BRANCH}
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
