# How to use cinc2dot.pl
```
yum install graphviz
yum install gv

\$ ./cinclude2dot.pl > source.dot
\$ neato -Tps source.dot > source.ps
```
# Include what you use
https://github.com/include-what-you-use/include-what-you-use

## Build iwyu for make
* The following packages installed:
```
    llvm-<version>-dev
    libclang-<version>-dev
    clang-<version>
```
yum install clang clang-devel llvm-devel llvm-static

* clone iwyu
git clone https://github.com/include-what-you-use/include-what-you-use.git

* Check clang/lvm version (X.Y) (example: 3.4)
git checkout clang_3.4

* Build iwyu
```
#cmake -G "Unix Makefiles" -DIWYU_LLVM_ROOT_PATH=/usr/lib64/llvm ../include-what-you-use
cmake ../ -DLLVM_PATH=/usr/lib64/llvm
```
# Using with CMake

```
yum install iwyu
```
```
CMake has grown native support for IWYU as of version 3.3. See their documentation for CMake-side details.
The CMAKE_CXX_INCLUDE_WHAT_YOU_USE option enables a mode where CMake first compiles a source file, and then runs IWYU on it.
Use it like this:
```
```
mkdir build && cd build
CC="clang" CXX="clang++" cmake -DCMAKE_CXX_INCLUDE_WHAT_YOU_USE="/usr/bin/iwyu;-Xiwyu;any;-Xiwyu;iwyu;-Xiwyu;args" 
```
The option appears to be separately supported for both C and C++, so use CMAKE_C_INCLUDE_WHAT_YOU_USE for C code.

