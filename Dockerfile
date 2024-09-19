# ARG BASE=none
ARG BASE=ubuntu:22.04
FROM ${BASE}

ARG PYVER=3.12

ARG PIP_OPT=""

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends software-properties-common && \
    apt-get install -y --no-install-recommends \
    build-essential \
    bzip2 \
    ca-certificates \
    cmake \
    curl \
    dpkg-dev \
    g++ \
    gcc \
    git \
    libblas-dev \
    libblas3 \
    libc6-dev \
    libeigen3-dev \
    libexpat1-dev \
    libxext6 \
    libxml2-dev \
    make \
    netbase \
    openssl \
    tk-dev \
    unzip \
    wget \
    sudo ssh \
    libcairo2 \
    gpg-agent \
    bison flex libssl-dev less emacs \
    && \
    add-apt-repository ppa:deadsnakes/ppa \
    && \
    apt-get install -y --no-install-recommends \
    libpython${PYVER}-dev \
    python${PYVER} \
    python${PYVER}-venv \
    python${PYVER}-distutils \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# CMake
WORKDIR /tmp/src
ARG CMAKE_VER="3.28.1"
RUN wget -q https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}.tar.gz && \
    tar zxf cmake-${CMAKE_VER}.tar.gz && \
    cd cmake-${CMAKE_VER} && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make -j $(nproc) && \
    make install && \
    cd .. && \
    rm -rf cmake-*

# bootstrap python pip
ENV PYTHON=python${PYVER}
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | $PYTHON

ARG BASEDIR=/opt

##########
# Install boost
ARG BOOST_MINOR_VER=84
ARG BOOST_DOWNLOAD_URL=https://boostorg.jfrog.io/artifactory/main/release/1.$BOOST_MINOR_VER.0/source/boost_1_${BOOST_MINOR_VER}_0.tar.bz2
ARG BOOST_INST_PATH=$BASEDIR/boost_1_84_0

WORKDIR /tmp/src
RUN curl -LO ${BOOST_DOWNLOAD_URL} && \
    tar --bzip2 -xf boost_1_${BOOST_MINOR_VER}_0.tar.bz2 && \
    cd boost_1_${BOOST_MINOR_VER}_0 && \
    bash bootstrap.sh && \
    ./b2 \
    linkflags='-Wl,-rpath='\''$ORIGIN'\''' \
    --prefix=${BOOST_INST_PATH} \
    --with-date_time \
    --with-filesystem \
    --with-iostreams \
    --with-system \
    --with-thread \
    --with-chrono \
    --with-timer \
    -d0 \
    link=shared threading=multi -j $(nproc) install && \
    rm -rf /tmp/src


##########
# Install CGAL

ARG CGAL_VER=4.14.3
ARG CGAL_DOWNLOAD_URL=https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-${CGAL_VER}/CGAL-${CGAL_VER}.tar.xz
ARG CGAL_INST_PATH=${BASEDIR}/CGAL-${CGAL_VER}

WORKDIR /tmp/src
RUN wget --progress=dot:mega ${CGAL_DOWNLOAD_URL} && \
    tar xJf CGAL-${CGAL_VER}.tar.xz && \
    cd CGAL-${CGAL_VER} && \
    mkdir -p build && cd build && \
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=$CGAL_INST_PATH \
    -DCMAKE_BUILD_TYPE="Release" \
    -DBOOST_ROOT=${BOOST_INST_PATH} \
    -DWITH_CGAL_Qt5=OFF \
    -DWITH_CGAL_ImageIO=OFF \
    -DCGAL_DISABLE_GMP=TRUE \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=FALSE && \
    make -j 8 && \
    make install && \
    rm -rf /tmp/src

##########
# Install fftw3

ARG FFTW_VER=3.3.10
ARG FFTW_DOWNLOAD_URL=https://www.fftw.org/fftw-${FFTW_VER}.tar.gz
ARG FFTW_INST_PATH=${BASEDIR}/fftw-${FFTW_VER}

WORKDIR /tmp/src
RUN wget --progress=dot:mega ${FFTW_DOWNLOAD_URL} && \
    tar xzf fftw-${FFTW_VER}.tar.gz && \
    cd fftw-${FFTW_VER} && \
    env CFLAGS="-fPIC" ./configure --prefix=$FFTW_INST_PATH \
    --enable-float \
    --disable-fortran && \
    make -j 8 && \
    make install && \
    rm -rf /tmp/src

##########
# Install lcms2

ARG LCMS2_VER=2.15
ARG LCMS2_DOWNLOAD_URL=https://github.com/mm2/Little-CMS/releases/download/lcms${LCMS2_VER}/lcms2-${LCMS2_VER}.tar.gz
ARG LCMS2_INST_PATH=${BASEDIR}/lcms2-${LCMS2_VER}

WORKDIR /tmp/src
RUN wget --progress=dot:mega $LCMS2_DOWNLOAD_URL && \
    tar xzf lcms2-${LCMS2_VER}.tar.gz && \
    cd lcms2-${LCMS2_VER} && \
    env CFLAGS="-fPIC" ./configure \
    --prefix=$LCMS2_INST_PATH \
    --enable-static --disable-shared && \
    make -j 8 && \
    make install && \
    rm -rf /tmp/src

# ##########
# # Install glew

# ARG GLEW_VER=2.1.0
# ARG GLEW_DOWNLOAD_URL=https://sourceforge.net/projects/glew/files/glew/${GLEW_VER}/glew-${GLEW_VER}.tgz/download
# ARG GLEW_INST_PATH=${BASEDIR}/glew-${GLEW_VER}

# WORKDIR /tmp/src
# RUN wget --content-disposition $GLEW_DOWNLOAD_URL -O glew-${GLEW_VER}.tgz && \
#     tar xzf glew-${GLEW_VER}.tgz && \
#     cd glew-${GLEW_VER} && \
#     make \
#     CC="gcc" \
#     GLEW_PREFIX=$GLEW_INST_PATH \
#     GLEW_DEST=$GLEW_INST_PATH \
#     install && \
#     rm -rf /tmp/src

