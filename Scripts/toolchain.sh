git clone --depth 1 --shallow-submodules --recursive https://github.com/raphaelmaguet/Open3D.git
cd Open3D

sh ios/all.sh

mv `find . -name \*.xcframework` .
