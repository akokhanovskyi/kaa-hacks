#
# Copyright 2014-2015 CyberVision, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#!/bin/bash


function help {
    echo "Choose one of the following: {build|run|deploy|clean}"
    exit 1
}

APP_NAME="dream_notifier"
PROJECT_HOME=$(pwd)
BUILD_DIR="build"
LIBS_PATH="libs"
KAA_LIB_PATH="$LIBS_PATH/kaa"
KAA_C_LIB_HEADER_PATH="$KAA_LIB_PATH/src"
KAA_CPP_LIB_HEADER_PATH="$KAA_LIB_PATH/kaa"
KAA_SDK_TAR="kaa-client*.tar.gz"

function build_kaasdk {
    echo "Building Kaa SDK..."
    if [[ ! -d "$KAA_C_LIB_HEADER_PATH" &&  ! -d "$KAA_CPP_LIB_HEADER_PATH" ]]
    then
        KAA_SDK_TAR_NAME=$(find $PROJECT_HOME -iname $KAA_SDK_TAR)

        if [ -z "$KAA_SDK_TAR_NAME" ]
        then
            echo "Please put Kaa C SDK tarball under $KAA_LIB_PATH and re-run this script."
            exit 1
        fi

        mkdir -p $KAA_LIB_PATH &&
        tar -zxf $KAA_SDK_TAR_NAME -C $KAA_LIB_PATH
    fi

    if [ ! -d "$KAA_LIB_PATH/$BUILD_DIR" ]
    then
        cd $KAA_LIB_PATH &&
        mkdir -p $BUILD_DIR && cd $BUILD_DIR &&
        cmake -DKAA_DEBUG_ENABLED=1 \
              -DKAA_WITHOUT_EVENTS=1 \
              -DKAA_WITHOUT_LOGGING=1 \
              -DKAA_MAX_LOG_LEVEL=3 \
              ..
    fi

    cd "$PROJECT_HOME/$KAA_LIB_PATH/$BUILD_DIR"
    make -j4 &&
    cd $PROJECT_HOME
}

function build_app {
    echo "Building $APP_NAME..."
    cd $PROJECT_HOME &&
    mkdir -p "$PROJECT_HOME/$BUILD_DIR" &&
    cp "$KAA_LIB_PATH/$BUILD_DIR/"libkaa* "$PROJECT_HOME/$BUILD_DIR/" &&
    cd $BUILD_DIR &&
    cmake -DAPP_NAME=$APP_NAME ..
    make
}

function clean {
    echo "Cleaning up..."
    rm -rf "$KAA_LIB_PATH/$BUILD_DIR"
    rm -rf "$PROJECT_HOME/$BUILD_DIR"
}

function run {
    echo "Starting $APP_NAME..."
    cd "$PROJECT_HOME/$BUILD_DIR"
    ./$APP_NAME
}



if [ $# -eq 0 ]
then
    help
fi

for cmd in $@
do
case "$cmd" in
    build)
        build_kaasdk &&
        build_app
    ;;

    run)
        run
    ;;

    deploy)
        clean
        build_kaasdk
        build_app
        run
    ;;

    clean)
        clean
    ;;

    *)
        help
    ;;
esac
done
