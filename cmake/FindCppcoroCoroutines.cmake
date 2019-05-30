include(CheckCXXCompilerFlag)
include(CheckIncludeFileCXX)
include(FindPackageHandleStandardArgs)

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(Coroutines_SUPPORTS_MS_FLAG_STRING /await /await:heapelide)
else()
    set(Coroutines_SUPPORTS_MS_FLAG_STRING /await)
endif()
check_cxx_compiler_flag("${Coroutines_SUPPORTS_MS_FLAG_STRING}" Coroutines_SUPPORTS_MS_FLAG)
if(DEFINED __cpp_coroutines)
    if( (DEFINED __clang__) AND (__cpp_coroutines GREATER_EQUAL 201903) ) # https://reviews.llvm.org/D33536
	# TODO: Add more compilers' __cpp_coroutines version
	#  OR ( (DEFINED __GNU__) AND (NOT DEFINED __clang__)  AND (__cpp_coroutines GREATER_EQUAL ??????) )
	#  OR ( (DEFINED _MSC_VER) AND (__cpp_coroutines GREATER_EQUAL ??????) )
        set(Coroutines_SUPPORTS_GNU_FLAG_STRING -std=c++2a)
	endif()    
endif()
if(NOT DEFINED Coroutines_SUPPORTS_GNU_FLAG_STRING)
    set(Coroutines_SUPPORTS_GNU_FLAG_STRING -fcoroutines-ts)
endif()
check_cxx_compiler_flag("${Coroutines_SUPPORTS_GNU_FLAG_STRING}" Coroutines_SUPPORTS_GNU_FLAG)
if(Coroutines_SUPPORTS_MS_FLAG OR Coroutines_SUPPORTS_GNU_FLAG)
    set(Coroutines_COMPILER_SUPPORT ON)
endif()

if(Coroutines_SUPPORTS_MS_FLAG)
    check_include_file_cxx("coroutine" Coroutines_STANDARD_LIBRARY_SUPPORT ${Coroutines_SUPPORTS_MS_FLAG_STRING})
    check_include_file_cxx("experimental/coroutine" Coroutines_EXPERIMENTAL_LIBRARY_SUPPORT ${Coroutines_SUPPORTS_MS_FLAG_STRING})
elseif(Coroutines_SUPPORTS_GNU_FLAG)
    check_include_file_cxx("coroutine" Coroutines_STANDARD_LIBRARY_SUPPORT ${Coroutines_SUPPORTS_GNU_FLAG_STRING})
    check_include_file_cxx("experimental/coroutine" Coroutines_EXPERIMENTAL_LIBRARY_SUPPORT ${Coroutines_SUPPORTS_GNU_FLAG_STRING})
endif()

if(Coroutines_EXPERIMENTAL_LIBRARY_SUPPORT OR Coroutines_STANDARD_LIBRARY_SUPPORT)
    set(Coroutines_LIBRARY_SUPPORT ON)
endif()

find_package_handle_standard_args(CppcoroCoroutines
    REQUIRED_VARS Coroutines_LIBRARY_SUPPORT Coroutines_COMPILER_SUPPORT
    FAIL_MESSAGE "Verify that the compiler and the standard library both support the Coroutines TS")

if(NOT CppcoroCoroutines_FOUND OR TARGET cppcoro::coroutines)
    return()
endif()

add_library(cppcoro::coroutines INTERFACE IMPORTED)
if(Coroutines_SUPPORTS_MS_FLAG)
    target_compile_options(cppcoro::coroutines INTERFACE ${Coroutines_SUPPORTS_MS_FLAG_STRING})
elseif(Coroutines_SUPPORTS_GNU_FLAG)
    target_compile_options(cppcoro::coroutines INTERFACE ${Coroutines_SUPPORTS_GNU_FLAG_STRING})
endif()
