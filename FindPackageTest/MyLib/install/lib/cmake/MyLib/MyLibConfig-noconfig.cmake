#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "MyLib::MyLib" for configuration ""
set_property(TARGET MyLib::MyLib APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(MyLib::MyLib PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libMyLib.a"
  )

list(APPEND _cmake_import_check_targets MyLib::MyLib )
list(APPEND _cmake_import_check_files_for_MyLib::MyLib "${_IMPORT_PREFIX}/lib/libMyLib.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
