#!/bin/bash
# g -- git terminal user interface
# author: proc0@github.com
# init global constants
SRC_EXE=${BASH_SOURCE[0]}
SRC_DIR=`dirname "$SRC_EXE"`
# load constants
. $SRC_DIR/src/doc/const.sh

# user configuration path
# TODO: copy config on install?
[ -f $(pwd)/$CFGNAME ] &&
CONFIG=$(pwd)/$CFGNAME ||
CONFIG=$SRC_DIR/$CFGNAME;
# command configuration path
CMD_CONFIG=$SRC_DIR/src/cmd/config.yml
MANUAL=$SRC_DIR/src/doc/manual.sh

# external libs
# bash-lambda (loads from .profile)
. $SRC_DIR/lib/kvbash.sh
# source libs
. $SRC_DIR/src/etc/lambda.sh 1>/dev/null
. $SRC_DIR/src/etc/index.sh #< utils ^
. $SRC_DIR/src/tui/index.sh #display
# load command handlers
. $SRC_DIR/src/cmd/index.sh
# load main subroutines
. $SRC_DIR/src/main.sh
# main :: IO String -> IO ()
main "$@"

