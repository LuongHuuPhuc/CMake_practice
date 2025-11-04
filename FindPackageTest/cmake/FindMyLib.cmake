# Day la file tu viet de mo phong tim thu vien MyLib
# Tep nay duoc goi khi ta dung find_package(MyLib)
# Cmake se tim file FindMyLib.cmake trong cac duong dan CMAKE_MODULE_PATH

# Duong dan den packaage MyLib
set(MYLIB_ROOT "${CMAKE_CURRENT_LIST_DIR}/../MyLib/install")

# Tim file header de kiem tra xem thu vien co ton tai khong
find_path(MYLIB_INCLUDE_DIR 
          NAMES mylib.hpp  # Ten file can tim
          PATHS "${MYLIB_ROOT}" # Duong dan 
          PATH_SUFFIXES include) # Duong dan kem

# Danh sach cac thu vien .a hoac .dll can lien ket
find_library(MYLIB_LIBRARY 
             NAMES MyLib
             PATHS "${MYLIB_ROOT}"
             PATH_SUFFIXES build lib)

if (MYLIB_INCLUDE_DIR AND MYLIB_LIBRARY)
    message(STATUS "Found MyLib in ${MYLIB_LIBRARY}")
    add_library(MyLib::MyLib STATIC IMPORTED)
    set_target_properties(MyLib::MyLib PROPERTIES
        IMPORTED_LOCATION "${MYLIB_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${MYLIB_INCLUDE_DIR}")                       
else()
    message(FATAL_ERROR "Could not find MyLib")
endif()