#!/bin/bash
# g -- git workflow toolkit
# author: proc0@github.com

#shortcut paths
SRC_EXE=${BASH_SOURCE[0]}
ROOT_DIR=`dirname "$SRC_EXE"`
SRC_DIR="$ROOT_DIR/src"
CFG_DIR="$SRC_DIR/cfg"
STR_DIR="$SRC_DIR/str"

# global string consts
. $STR_DIR/static.sh
. $CFG_DIR/g.conf.sh

# config paths
[ -f $(pwd)/$CFGNAME ] &&
	CONFIG=$(pwd)/$CFGNAME ||
	CONFIG=$CFG_DIR/$CFGNAME

# commands and help manual
CMD_CONFIG=$CFG_DIR/cmd.conf.yml
MANUAL=$STR_DIR/manual.sh

# external libs
. $ROOT_DIR/lib/kvbash.sh
# source libs
. $SRC_DIR/etc/lambda.sh #fp utils
. $SRC_DIR/etc/index.sh #utils
. $SRC_DIR/tui/index.sh #display
. $SRC_DIR/cmd/index.sh #cmd handlers
# main subroutines
. $SRC_DIR/main.sh

# -
main "$@"

