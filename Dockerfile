FROM ubuntu:16.04

USER root
WORKDIR /root

RUN apt-get update && apt-get install -y \
    less man-db \
    wget curl ca-certificates \
    \
    build-essential \
    binutils gcc g++ gfortran \
    python \
    autoconf automake autogen libtool make cmake \
    git-core \
    \
    screen parallel mc \
    \
    && locale-gen en_US.UTF-8


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install CERN ROOT:

COPY provisioning/install-sw-scripts/root-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/root/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/root/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/root/man:$MANPATH" \
    PYTHONPATH="/opt/root/lib:$PYTHONPATH" \
    CMAKE_PREFIX_PATH="/opt/root;$CMAKE_PREFIX_PATH" \
    JUPYTER_PATH="/opt/root/etc/notebook:$JUPYTER_PATH" \
    ROOTSYS="/opt/root"

RUN true \
    && apt-get install --no-install-recommends -y \
        libglu1-mesa-dev libjpeg-dev libpng-dev libtiff-dev libx11-dev \
        libxext-dev libxft-dev libxml2-dev libxpm-dev python-dev \
    && provisioning/install-sw.sh root 6.08.00 /opt/root


# Install Jupyter:

RUN true \
    && apt-get install --no-install-recommends -y \
        libglu1-mesa-dev libjpeg-dev libpng-dev libtiff-dev libx11-dev \
        libxext-dev libxft-dev libxml2-dev libxpm-dev python-dev \
    && provisioning/install-sw.sh root 6.08.00 /opt/root

RUN true \
    && apt-get install -y python-pip python-setuptools \
    && pip install --upgrade pip \
    && pip install jupyter metakernel

EXPOSE 8888


# Install BAT:

COPY provisioning/install-sw-scripts/bat-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/bat/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/bat/lib:$LD_LIBRARY_PATH" \
    CPATH="/opt/bat/include:$CPATH" \
    PKG_CONFIG_PATH="/opt/bat/lib/pkgconfig:"

RUN true \
    && apt-get install -y \
    && provisioning/install-sw.sh bat bat/master /opt/bat


# Clean up:

# RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Environment variables for swmod and "/user":

ENV \
    SWMOD_HOSTSPEC="linux-ubuntu-16.04-x86_64-bce18b68" \
    SWMOD_INST_BASE="/user/.local/sw" \
    SWMOD_MODPATH="/user/.local/sw" \
    \
    PATH="/user/.local/bin:$PATH" \
    LD_LIBRARY_PATH="/user/.local/lib:$LD_LIBRARY_PATH" \
    MANPATH="/user/.local/share/man:$MANPATH" \
    PKG_CONFIG_PATH="/user/.local/lib/pkgconfig:$PKG_CONFIG_PATH" \
    CPATH="/user/.local/include:$CPATH" \
    PYTHONUSERBASE="/user/.local" \
    PYTHONPATH="/user/.local/lib/python2.7/site-packages:$PYTHONPATH"


# Final steps

CMD /bin/bash
