#!/bin/bash
# g -- git shortcut tool 
# author: proc0@github.com
# init global resources
src_exe=${BASH_SOURCE[0]}
src_dir=`dirname "$src_exe"`
# requires kvbash, bash-lamda
. $src_dir/lib/kvbash.sh
# careful reordering !
. $src_dir/src/doc/const.sh
. $src_dir/src/etc/lambda.sh 1>/dev/null
. $src_dir/src/etc/index.sh
. $src_dir/src/gui/index.sh
# set config filepath
[ -f "$(pwd)/$CFGNAME" ] && \
config="$(pwd)/$CFGNAME" || \
config="$src_dir/$CFGNAME"
# entrypoint
. $src_dir/src/main.sh
#:<<proc0
#        _,.---'---.,_
#     ,-*             *-.
#   ,^                   ^.
#  /          ⛧           |.
# (@.                     .\' 
# |#$)^-  .~.,   .~ .  -^(@ )
# \&( .--..   ) (   .--.. ): 
#  ($(   _ '-. V ,-' _   ) /
#  )#! .(Q). / A \ .(Q). !  
# .-%(::,.--" /^\ "--.,::) -.
# (#&-~  _.  (_|_)   ._  -  )
#  \M-%,T# : . '       T._,/
#       )#)$ ) : ( ( .(
#       [.M:#:.:.: : ,]
#        '*($(_|_),)-'
# proc0
main $@

