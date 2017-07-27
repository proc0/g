#!/bin/bash
# g -- git workflow toolkit
# author: proc0@github.com

SRC_EXE=${BASH_SOURCE[0]}
SRC_DIR=`dirname "$SRC_EXE"`

# global string constants
. $SRC_DIR/str/static.sh
. $SRC_DIR/cfg/g.conf.sh

# config paths
[ -f $(pwd)/$CFGNAME ] &&
	CONFIG=$(pwd)/$CFGNAME ||
	CONFIG=$SRC_DIR/cfg/$CFGNAME

CMD_CONFIG=$SRC_DIR/cfg/cmd.conf.yml
MANUAL=$SRC_DIR/str/manual.sh

# external libs
. $SRC_DIR/lib/kvbash.sh
# source libs
. $SRC_DIR/src/etc/index.sh #utils
. $SRC_DIR/src/tui/index.sh #display
. $SRC_DIR/src/cmd/index.sh #cmd handlers
# main subroutines
. $SRC_DIR/src/main.sh

# -
main "$@"

