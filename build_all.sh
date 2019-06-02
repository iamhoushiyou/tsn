#!/usr/bin/env bash
CAFFE_USE_MPI=${1:-OFF }
CAFFE_MPI_PREFIX=${MPI_PREFIX:-""}

# install common dependencies: OpenCV
# adpated from OpenCV.sh
version="3.1.0"

echo "date"
echo "Building OpenCV" $version
#[[ -d 3rd-party ]] || mkdir 3rd-party/
cd "3rd-party/opencv-"$version
#if [ ! -d "opencv-$version" ]; then
#    echo "Downloading OpenCV" $version
   # git clone --recursive -b 3.4 https://github.com/opencv/opencv opencv-$version
#    http_proxy=http://localhost:8118  git clone --recursive -b 3.1.0  https://github.com/opencv/opencv opencv-$version  
#fi

#echo "Building OpenCV" $version
#cd opencv-$version
#if [ ! -d "opencv-contrib-$version" ]; then
#	echo "downloading opencv-contrib-" $version
#	http_proxy=http://localhost:8118  git clone --recursive -b 3.1.0  https://github.com/opencv/opencv_contrib.git  opencv-contrib-$version
#fi
pwd
#cp ../../OpenCVDetectCUDA.cmake cmake/ 

#echo "copy finished" $(vim $(ls cmake |grep "OpenCVDetectCUDA.cmake"))
echo $(ls opencv-contrib-3.1.0)
[[ -d build ]] || mkdir build
cd build
echo $(ls ../opencv_contrib/modules)
cmake -D CMAKE_BUILD_TYPE=RELEASE   -D WITH_V4L=ON  -D WITH_CUDA=ON  -D ENABLE_PRECOMPILED_HEADERS=OFF -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules ..  
if make -j32 ; then
    cp lib/cv2.so ../../../
    echo "OpenCV" $version "built."
else
    echo "Failed to build OpenCV. Please check the logs above."
    exit 1
fi

# build dense_flow
cd ../../../

echo "Building Dense Flow"
cd lib/dense_flow
[[ -d build ]] || mkdir build
cd build
OpenCV_DIR=../../../3rd-party/opencv-$version/build/ cmake .. -DCUDA_USE_STATIC_CUDA_RUNTIME=OFF
if make -j ; then
    echo "Dense Flow built."
else
    echo "Failed to build Dense Flow. Please check the logs above."
    exit 1
fi
## build caffe
echo "Building Caffe, MPI status: ${CAFFE_USE_MPI}"
cd ../../caffe
[[ -d build ]] || mkdir build
cd build
if [ "$CAFFE_USE_MPI" == "MPI_ON" ]; then
OpenCV_DIR=../../../3rd-party/opencv-$version/build/ cmake .. -DUSE_MPI=ON -DMPI_CXX_COMPILER="/usr/bin/mpicxx" -DCUDA_USE_STATIC_CUDA_RUNTIME=ON
else
OpenCV_DIR=../../../3rd-party/opencv-$version/build/ cmake .. -DCUDA_USE_STATIC_CUDA_RUNTIME=OFF
fi
if make -j32 install ; then
    echo "Caffe Built."
    echo "All tools built. Happy experimenting!"
    cd ../../../
else
    echo "Failed to build Caffe. Please check the logs above."
    exit 1

fi
