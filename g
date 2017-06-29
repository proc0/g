#!/bin/bash
# g -- git shortcut tool 
# author: proc0@github.com
# init global path vars
src_exe=${BASH_SOURCE[0]}
src_dir=`dirname "$src_exe"`
# user configuration path
[ -f $(pwd)/$CFGNAME ] &&
config=$(pwd)/$CFGNAME ||
config=$src_dir/$CFGNAME;
# command configuration path
cmd_config=$src_dir/src/cmd/config.yml

# external libs
# bash-lambda (loads from .profile)
. $src_dir/lib/kvbash.sh
# internal subroutines
# careful reordering !
. $src_dir/src/doc/const.sh
. $src_dir/src/etc/lambda.sh 1>/dev/null
. $src_dir/src/etc/index.sh
. $src_dir/src/tui/index.sh
# load command handlers
. $src_dir/src/cmd/index.sh
# load main subroutines
. $src_dir/src/main.sh
# main :: IO String -> IO ()
main "$@"

