#!/bin/bash
# g -- git workflow toolkit
# author: proc0@github.com

# alias source paths
SRC_EXE=${BASH_SOURCE[0]}
ROOT_DIR=`dirname "$SRC_EXE"`
SRC_DIR="$ROOT_DIR/src"
CFG_DIR="$SRC_DIR/cfg"
STR_DIR="$SRC_DIR/str"

# load global consts
. $STR_DIR/static.sh
. $CFG_DIR/g.conf.sh

# set resource paths
# ------------------
# global config
[ -f $(pwd)/$CFGNAME ] &&
	CONFIG=$(pwd)/$CFGNAME ||
	CONFIG=$CFG_DIR/$CFGNAME
# command config
CMD_CONFIG=$CFG_DIR/cmd.conf.yml
# help manual
MANUAL=$STR_DIR/manual.sh

# load subroutines
# ----------------
# external libs
. $ROOT_DIR/lib/kvbash.sh
# source libs
. $SRC_DIR/lib/lambda.sh
. $SRC_DIR/lib/index.sh
. $SRC_DIR/tui/index.sh
. $SRC_DIR/cmd/index.sh
# main subroutines
. $SRC_DIR/main.sh

# run ...
# -------
# u fools
main "$@"
