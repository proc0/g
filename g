#!/bin/bash
# g -- git workflow toolkit
# author: proc0@github.com

# global path constants
SRC_EXE=${BASH_SOURCE[0]}
SRC_DIR=`dirname "$SRC_EXE"`

# global string constants
. $SRC_DIR/src/doc/const.sh

[ -f $(pwd)/$CFGNAME ] &&
CONFIG=$(pwd)/$CFGNAME ||
CONFIG=$SRC_DIR/$CFGNAME;
# command configuration path
CMD_CONFIG=$SRC_DIR/src/cmd/config.yml
MANUAL=$SRC_DIR/src/doc/manual.sh

# external libs
. $SRC_DIR/lib/kvbash.sh
# source libs
. $SRC_DIR/src/etc/lambda.sh 1>/dev/null
. $SRC_DIR/src/etc/index.sh #< utils ^
. $SRC_DIR/src/tui/index.sh #display
# command handlers
. $SRC_DIR/src/cmd/index.sh
# main subroutines
. $SRC_DIR/src/main.sh

# main :: IO String -> IO ()
main "$@"

