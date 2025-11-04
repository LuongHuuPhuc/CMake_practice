### Flow khi `find_package()` được gọi
- Lệnh trên có chức năng tìm kiếm và sử dụng các thư viện ngoài dự án, bao gồm việc xác định các tệp cấu hình cần thiết như `.cmake` để xác định vị trí và thiết lập các cờ biên dịch, thư viện liên kết và các thành phând của thư viện đó
- Lệnh sẽ tìm kiếm một thư viện theo tên chỉ định trong nhiều vị trí có thể có. Sau khi tìm thấy thư viện, nó sẽ tải các tệp cấu hình `.cmake` được liên kết với thư viện đó.
- Các tệp cấu hình `.cmake` này thường sẽ thiết lập các biến quan trọng sau:
    - Target: Tên của mục tiêu thư viện được định nghĩa để liên kết
    - Include_dirs: Đường dẫn đến các tệp tiêu đề (Ví dụ: `MYLIB_INCLUDE_DIR`)
    - Link_libs: Danh sách các thư viện cần liên kết (Ví dụ: `MYLIB_LIBRARY`)
- Khi chạy lệnh `find_package(<Package_name> [REQUIRED] [CONFIG|MODULE])`, CMake sẽ tìm kiếm package 2 mode 
    - Mode `CONFIG`: file `.cmake` có định dạng `<name>Config.cmake` hoặc `<name>-config.cmake`
    - Mode `MODULE`: file `.cmake` thường có dạng 
như sau:
1. Nếu chỉ định rõ mode (`CONFIG` hoặc `MODULE`)
    - CMake chỉ tìm theo mode :
    - Ví du: `find_package(MyLib CONFIG REQUIRED)` -> Chỉ tìm `MyLIbConfig.cmake` hoặc `MyLib-config.cmake`

2. Nếu không chỉ định rõ mode (mặc định)
CMake thực hiện theo thứ tự ưu tiên sau:  
- Module Mode - tìm file module trong `CMAKE_MODULE_PATH` hoặc các module tích hợp sẵn của CMake file có dạng `Find<Package_name>.cmake`
- Config Mode - nếu không thấy module, Cmake mới tìm file config có dạng `<Package_name>Config.cmake` trong các đường dẫn chuẩn như: 
    - `${CMAKE_PREFIX_PATH}`
    - `/usr/lib/cmake/<Package_name>`
    - `/usr/share/<Package_name>`
    - Thư mục `install/` cua project đã export targets qua `install(EXPORT ...)`

### Giải thích toàn bộ lệnh `install()` trong file CmakeLists.txt
- `install()` là lệnh dùng để sinh và chỉ định file của dự án vào 1 vị trí cụ thể trên hệ thống sau khi quá trình biên dịch hoàn tất
- Nó cho phép bạn định nghĩa các quy tắc để sao chép tệp từ thư mục `/build` sang các thư mục được chỉ định, giúp đóng gói và phân phối dự án một cách có tổ chức

#### 1. `install(TARGETS ...)` - chỉ định cách cài đặt (install) target khi chạy `cmake --install`
Cú pháp cơ bản 
```cmake
install(TARGETS <tên target>
        EXPORT <export_name>
        [ARCHIVE DESTINATION <path>]
        [LIBRARY DESTINATION <path>]
        [RUNTIME DESTINATION <path>])
```
Giải thích từng phần:
|Thành phần | Ý nghĩa |
|-----------|---------|
|`TARGETS MyLib` | Chỉ định target mà bạn đã định nghĩa ở trên (bằng `add_library(MyLib STATIC ...)`). Đây chính là đối tượng được build (`libMyLib.a` `MyLib.dll`,...) sẽ được cài đặt (install) ra thư mục `install`|
|`EXPORT MyLibTargets` |Tạo ra một nhóm export tên là `MyLibTargets` => Nhóm này chứa thông tin mô tả về target MyLib (đường dẫn include, flags, library path,...). Nhóm này sau đó được dùng để sinh file `MyLibConfig.cmake` ở lệnh tiếp theo|
|`ARCHIVE DESTINATION lib`|Chỉ nơi copy file.a/.lib thư viện tĩnh (static library) khi install -> Sẽ chép vào `<prefix>/lib`|
|`LIBRARY DESTINATION lib`| Chỉ nơi copy file.so/.dylib (shared library) nếu là thư viện động -> Cũng chép vào `<prefix>/lib`|
|`RUNTIME DESTINATION lib`|Chỉ nơi copy file .exe hoặc .dll (chạy được) -> Cài đặt vào `<prefix>/bin`|

- Như vậy, sau khi chạy:
```bash
cmake --install build --prefix ../MyLib/install
```
Thư viện sẽ xuất hiện ở:
```scss
install/
├── lib/
│   ├── libMyLib.a
│   └── ...
└── bin/
```

#### 2. `install(FILES mylib.hpp DESTINATION include)` - copy file header
Giải thích:
- `FILES mylib.hpp` - chỉ rõ file cần install (thường là header hoặc file cấu hình)
- `DESTINATION include` - chỉ thư mục đích nằm trong prefix (ở đây là `<prefix>/include`)

Kết quả: Sau khi cài đặt, bạn sẽ có
```bash
install/include/mylib.hpp
```
- Thường dòng này sẽ được lặp lại nhiều lần nếu bạn có nhiều file header hoặc thư mục `include/`

#### 3. `install(EXPORT...)` - xuất "cấu hình CMake" để project khác có thể dùng `find_package()`
Cú pháp cơ bản 
```cmake 
install(EXPORT <export_name>
        FILE <config_file_name>
        NAMESPACE <prefix>
        DESTINATION <path>)
```
Giải thích từng phần:
|Thành phần|Ý nghĩa|
|----------|-------|
|`EXPORT MyLibTargets`|Chính là export group bạn đã định nghĩa trong `install(TARGETS...)` -> Lệnh này sẽ đọc thông tin từ `MyLibTargets` và sinh ra một file `.cmake` chứa metadata của target MyLib|
|`FILE MyLibConfig.cmake`|Tên file sẽ được sinh ra (ví dụ: MyLibConfig.cmake) File này là file Config Mode mà project khác sẽ tìm thấy khi gọi `find_package(MyLib)`|
|`NAMESPACE MyLib:`| Khi project khác `find_package(MyLib)` thành công, họ sẽ có thể gọi target dưới tên `MyLib::MyLib` ví dụ lệnh `target_link_libraries(main PRIVATE MyLib::MyLib)`|
|`DESTINATION lib/cmake/MyLib`|Đường dẫn lưu file `MyLibConfig.cmake` (tính từ prefix)|

### Note
- `build/` - Nơi CMake biên dịch tạm thời (obj, exe, lib)
- `install/` - nơi sản phẩm cuối cùng được xuất bản ra (giống như thư mục `bin/`, `include/`, `lib/` khi cài phần mềm thật)
- Lệnh `cmake --install build --prefix ../MyLib/install` -> Chép file từ `build` sang folder `install` đúng cấu trúc chuẩn để sau này project khác có thể dùng (`find_package()`, `target_link_libraries()`,...)
- Nói đơn giản: **`build` để xây, `install` để phát hành**
