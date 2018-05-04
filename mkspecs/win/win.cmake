# Check Windows Version
string(REPLACE "." ";" KERNEL_VERSION_LIST ${CMAKE_SYSTEM_VERSION})
list(LENGTH KERNEL_VERSION_LIST KERNEL_VERSION_LIST_LENGTH)
if(KERNEL_VERSION_LIST_LENGTH GREATER "0")
	list(GET KERNEL_VERSION_LIST 0 KERNEL_VERSION_MAJOR)
endif()
if(KERNEL_VERSION_LIST_LENGTH GREATER "1")
	list(GET KERNEL_VERSION_LIST 1 KERNEL_VERSION_MINOR)
endif()
if(KERNEL_VERSION_LIST_LENGTH GREATER "2")
	list(GET KERNEL_VERSION_LIST 2 KERNEL_VERSION_PATCH)
endif()

# Set long path support for windows 10
if(KERNEL_VERSION_MAJOR GREATER "6")
	if(NOT ENABLE_LONG_PATH_SUPPORT)
		message(STATUS "HINT: Some libraries will only compile if you enable long path support in regedit. You may want to enable ENABLE_LONG_PATH_SUPPORT so cmake will do this for you.")
	else(NOT ENABLE_LONG_PATH_SUPPORT)
		file(WRITE ${CMAKE_BINARY_DIR}/removeLimit.reg "Windows Registry Editor Version 5.00 \r\n [HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\FileSystem] \r\n \"LongPathsEnabled\"=dword:00000001")
		execute_process(COMMAND regedit /S ${CMAKE_BINARY_DIR}/removeLimit.reg RESULT_VARIABLE SET_LONG_PATH_RESULT)
		message(STATUS "Set long path support returned: ${SET_LONG_PATH_RESULT}")
	endif()
else(KERNEL_VERSION_MAJOR GREATER "6")
	message(WARNING "The Windows Version you are using doesn't support paths longer than 260 characters. Some libraries will not compile.")
endif()

if(MSVC)
    # Common targets other projects may depend on
    set(PERL_PATH "${CMAKE_BINARY_DIR}/Perl/src/Perl/perl/site/bin;${CMAKE_BINARY_DIR}/Perl/src/Perl/perl/bin;${CMAKE_BINARY_DIR}/Perl/src/Perl/c/bin")
    ExternalProject_Add(Perl
        PREFIX Perl
        URL http://strawberryperl.com/download/5.26.1.1/strawberry-perl-5.26.1.1-32bit-portable.zip
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "configure dummy"
        BUILD_COMMAND ${CMAKE_COMMAND} -E echo "build dummy"
        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "install dummy"
    )

    set(PYTHON_PATH "${CMAKE_BINARY_DIR}/Python/src/Python")
    ExternalProject_Add(Python
        PREFIX Python
        URL http://www.python.org/ftp/python/3.7.0/python-3.7.0a4-embed-win32.zip
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "configure dummy"
        BUILD_COMMAND ${CMAKE_COMMAND} -E echo "build dummy"
        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "install dummy"
    )

    set(NASM_PATH "${CMAKE_BINARY_DIR}/nasm/src/nasm")
    ExternalProject_Add(nasm
        PREFIX nasm
        URL http://www.nasm.us/pub/nasm/releasebuilds/2.13/win32/nasm-2.13-win32.zip
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "configure dummy"
        BUILD_COMMAND ${CMAKE_COMMAND} -E echo "build dummy"
        INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "install dummy"
    )

	get_filename_component(MY_COMPILER_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
	find_file(VCVARSALL vcvarsall.bat "${MY_COMPILER_DIR}/.." "${MY_COMPILER_DIR}/../..")
	if(NOT VCVARSALL)
		find_file(VSDEVCMD vsdevcmd.bat "${MY_COMPILER_DIR}/.." "${MY_COMPILER_DIR}/../.." "${MY_COMPILER_DIR}/../../../../../../../Common7/Tools")
		if(VSDEVCMD)
			unset(VCVARSALL CACHE)
		endif()
	else()
		unset(VSDEVCMD CACHE)
	endif()

    # Write a script file that sets the msvc environment for vs 2013.
    if(VCVARSALL)
        # x86 | amd64 | arm | x86_amd64 | x86_arm | amd64_x86 | amd64_arm
        # x86 | amd64: native host
        # other: cross host
        if (CMAKE_SIZEOF_VOID_P MATCHES "8")
            set(VCVARSALL_OPTION "amd64")
        else()
            set(VCVARSALL_OPTION "x86")
        endif()
        file(WRITE ${CMAKE_BINARY_DIR}/setMsvcEnv.bat
        "
        call \"${VCVARSALL}\" ${VCVARSALL_OPTION}
        "
        )
    endif()

    # Write a script file that sets the msvc environment for vs 2015 and above.
    if(VSDEVCMD)
        # x86 | amd64 | arm | x86_amd64 | x86_arm | amd64_x86 | amd64_arm
        # x86 | amd64: native host
        # other: cross host
        if (CMAKE_SIZEOF_VOID_P MATCHES "8")
            set(VSDEVCMD_OPTION "amd64")
        else()
            set(VSDEVCMD_OPTION "x86")
        endif()
        file(WRITE ${CMAKE_BINARY_DIR}/setMsvcEnv.bat
        "
        call \"${VSDEVCMD}\" -arch=${VSDEVCMD_OPTION} -no_logo
        "
        )
    endif()
endif(MSVC)

if(MSVC)
    message(STATUS "Using MSVC generator: ${CMAKE_GENERATOR}")
    include_and_prepare(mkspecs/win/msvc/zlib.cmake)
    include_and_prepare(mkspecs/win/msvc/OpenSSL.cmake)
    include_and_prepare(mkspecs/win/msvc/sigar.cmake)
    include_and_prepare(mkspecs/win/msvc/Qt5.cmake)
    include_and_prepare(mkspecs/win/msvc/QtWebApp.cmake)
    include_and_prepare(mkspecs/win/msvc/ECM.cmake)
    include_and_prepare(mkspecs/win/msvc/KF5Kirigami2.cmake)
    include_and_prepare(mkspecs/win/msvc/x264.cmake)
    include_and_prepare(mkspecs/win/msvc/FFmpeg.cmake)
    include_and_prepare(mkspecs/win/msvc/QtAV.cmake)
    include_and_prepare(mkspecs/win/msvc/Xercesc.cmake)
elseif(MINGW)
    message(STATUS "Using minGW generator: ${CMAKE_GENERATOR}")
    include_and_prepare(mkspecs/win/minGW/zlib.cmake)
    include_and_prepare(mkspecs/win/minGW/OpenSSL.cmake)
    include_and_prepare(mkspecs/win/minGW/gsoap.cmake)
else(MSVC)
    message(FATAL_ERROR "Unsupported generator: ${CMAKE_GENERATOR}")
endif(MSVC)

# Write a batch file that sets some basic linker compiler search paths.
file(WRITE ${CMAKE_BINARY_DIR}/setSearchEnv.bat
"
set PATH=${EXTERNAL_BIN_PATH};${PYTHON_PATH};${PERL_PATH};${NASM_PATH};%PATH%
set LIB=${EXTERNAL_LIB_PATH};%LIB%
set INCLUDE=${EXTERNAL_INCLUDE_PATH};%INCLUDE%
set LIBRARY_PATH=${EXTERNAL_LIB_PATH};%LIBRARY_PATH%
set CPATH=${EXTERNAL_INCLUDE_PATH};%CPATH%
set CMAKE_PREFIX_PATH=${EXTERNAL_CMAKE_PREFIX_PATH};%CMAKE_PREFIX_PATH%
"
)

# Write a bash file that sets some basic linker compiler search paths.
string(REPLACE ";" "\":\"" EXTERNAL_BIN_PATH_STR "${EXTERNAL_BIN_PATH}")
string(REPLACE ";" "\":\"" EXTERNAL_LIB_PATH_STR "${EXTERNAL_LIB_PATH}")
string(REPLACE ";" "\":\"" EXTERNAL_INCLUDE_PATH_STR "${EXTERNAL_INCLUDE_PATH}")
string(REPLACE ";" "\":\"" EXTERNAL_CMAKE_PREFIX_PATH_STR "${EXTERNAL_CMAKE_PREFIX_PATH}")
file(WRITE ${CMAKE_BINARY_DIR}/setSearchEnv.sh
"
#!/bin/bash
PATH=\"${EXTERNAL_BIN_PATH_STR}\":\"${NASM_PATH}\":$PATH
LIB=\"${EXTERNAL_LIB_PATH_STR}\":$LIB
INCLUDE=\"${EXTERNAL_INCLUDE_PATH_STR}\":$INCLUDE
LIBRARY_PATH=\"${EXTERNAL_LIB_PATH_STR}\":$LIBRARY_PATH
CPATH=\"${EXTERNAL_INCLUDE_PATH_STR}\":$CPATH
CMAKE_PREFIX_PATH=\"${EXTERNAL_CMAKE_PREFIX_PATH_STR}\":$CMAKE_PREFIX_PATH
"
)
