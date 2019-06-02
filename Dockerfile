FROM nvidia/cuda:10.0-cudnn7-devel

ENV DEBIAN_FRONTEND=nointeractive
RUN apt-get update  && apt-get install -y tzdata software-properties-common && add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
RUN apt-get -qq install -y python2.7 libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler libatlas-base-dev unzip zip
RUN apt-get -y install --no-install-recommends libboost1.65-all-dev libgflags-dev libgoogle-glog-dev liblmdb-dev wget python-pip git-all libzip-dev 

COPY ccmake /home/cmake-3.14.3/
RUN echo $(ls /home/) && apt-get install -y vim
ENV CMAKE_ROOT=/home/cmake-3.14.3
ENV PATH=$PATH:$CMAKE_ROOT/bin:
RUN echo "##################### cmake-version  " $(cmake --version) "################"

RUN echo "install python"
# RUN PYTHON INSTALL
RUN pip install --upgrade pip setuptools wheel
RUN pip install numpy scipy 
RUN pip install sklearn scikit-image

RUN echo "install 2"
RUN apt-get -qq install  build-essential checkinstall pkg-config yasm libjpeg-dev libjasper1 libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev  libv4l-dev python-dev  libtbb-dev libqt4-dev libgtk2.0-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils


RUN echo "##################### cmake-version  " $(cmake --version) "################"
RUN touch /home/a.log && chmod 777 /home/a.log
RUN echo $( pkg-config --modversion opencv) >  /home/a.log

RUN echo "install python3"
RUN apt-get -qq install libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler libatlas-base-dev
RUN apt-get -qq install libgflags-dev libgoogle-glog-dev liblmdb-dev

# install Dense_Flow dependencies
RUN apt-get -qq install libzip-dev

WORKDIR /app

ADD . /app
# Get code

RUN pip install -r lib/caffe/python/requirements.txt

RUN echo "install finished"

RUN nvcc --version

ENV LIBRARY_PATH=/usr/local/cuda/lib64
RUN bash -e build_all.sh

RUN bash scripts/get_reference_models.sh
RUN bash scripts/get_init_models.sh

RUN pip install  protobuf
RUN pip install http://download.pytorch.org/whl/cu90/torch-0.3.1-cp27-cp27mu-linux_x86_64.whl 
RUN pip install torchvision 

RUN apt-get -qq install -y vim

CMD ["ipython"]

