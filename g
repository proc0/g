#!/bin/bash
# set -x

# g -- git shortcut tool 
# author: proc0@github.com

src_dir=~/Desktop/g
config=$src_dir/config.yml
#careful reordering !
. $src_dir/lib/kvbash.sh
. $src_dir/src/lambda.sh 1>/dev/null
. $src_dir/src/globals.sh
. $src_dir/src/manual.sh
. $src_dir/src/commands/index.sh
. $src_dir/src/gui/index.sh
. $src_dir/src/utils/index.sh

#main :: IO()
main() {
    [ -n "$1" ] || oops 13 NO_COMMAND

    #info commands have no dep options
    [ -n "$(get_info $1)" ] && get_info "$1" \
    | more && exit 0

    #test for environment errors
    env_err=$(env_ready $@)
    [ -n "$env_err" ] && oops 90 $env_err "$*"

    #main event
    local ret=0
    (clear_options && parse_config || ret=$?) \
    && exec_command "$@" || ret=$?

    #clean exit if zero
    [ $ret -eq 0 ] && exit 0
    #else error code for human :(
    err_key="`const KEY $ret`"
    [ -n $err_key ] && oops $ret $err_key "$@" \
    || oops 99 GENERIC "$@"
}
#exec_command :: $@ -> (()IO -> Int)
exec_command(){
    local ret=0
    local cmd=$1
    local argv=$@

    local opts=''
    #split between command and options:
    #if removing dash makes no diff
    #then match command; splice options
    #else match cmd-opt; splice options
    [[ "${cmd#*\-}" == "$cmd" ]] \
    && opts="${argv#*$cmd[ ]*}" \
    || opts="${argv#*[^-]*$cmd[ ]*}"

    (set_options "$opts" || ret=$?) \
    && get_command "$cmd" || ret=$?

    return $ret
}
#map command options to setters
#set_option :: $@ -> (()IO -> Int)
set_options() {
    local OPTIND
    local ret=0
    echo "parsing options $*"
    while getopts ":hvsl:b:m:u:c:k:n:o:t:d:" opt; do
        case "$opt" in
            #normal options w/ or w/o args
            n) set_option "name"   "$OPTARG";;
            o) set_option "output" "$OPTARG";;
            t) set_option "target" "$OPTARG";;
            #command shortcut option handling #LBMUCK
            #add option/command here & get_command & get_shortcut
            l|b|m|u|c|k|?)
                _opt="$opt"
                #when getopts can't parse option, it sets opts to ':'
                #check for this to make the switch case handle
                #shortcuts with required options and optional options
                [[ $_opt == ':' ]] && _opt="$1" || _opt="-$opt"

                local argval="$OPTARG"
                [[ "$OPTARG" == "${1#*-}" ]] && argval=''

                # echo "has value $has_value - $OPTARG"
                # def _has_value $has_value
                # def _argval $argval
                # [[ "$has_value" == 'true' ]] && def argval "$OPTARG" || def argval ''
                # echo "$argval"
                # def set_sc_opt set_shortcut_opt
                #nested single quotes work XD + argval at the end, maybe empty
                # get_sc_opt=$(fn label code '$set_sc_opt '$label' '$code' '$argval'')
                case "$_opt" in
                    #TODO: install codebase before deleting this
                    #set ret to errcode if option is required
                    #if the value is the flag itself, then no arg value
                    # -c) [[ "$OPTARG" != "${1#*-}" ]] && set_option "comment" "$OPTARG" || ret=14;;
                    # -k) [[ "$OPTARG" != "${1#*-}" ]] && set_option "name"    "$OPTARG" || ret=0;;
                    # *)  [[ "$OPTARG" != "${1#*-}" ]] && set_option "target"  "$OPTARG" || ret=0;;
                    # -c) set_shortcut_opt "$1" "$OPTARG" "comment" 14;;
                    # -k) set_shortcut_opt "$1" "$OPTARG" "name" 0;;
                    # *) set_shortcut_opt "$1" "$OPTARG" "target" 0;;
                    # -c) $get_sc_opt 'comment' 14;;
                    # -k) $get_sc_opt 'name'     0;;
                    # *)  $get_sc_opt 'target'   0;;
                    -c) set_option 'comment' "$argval" 14;;
                    -k) set_option 'name' "$argval";;
                    *) set_option 'target' "$argval";;
                esac
                # [ $ret -eq 0 ] && get_shortcut "$_opt" || ret=$?
                return $ret;;   
            #other options
            d) set_option "_debug" "$OPTARG";;
        esac
        # ret=$?
        #break on error
        # [ $ret -gt 0 ] && break
    done
    # [ $ret -eq 0 ] && shift "$((OPTIND-1))"
    shift "$((OPTIND-1))"
    return $ret
}
#TODO: read command configuration from
#      yaml file and programmatically
#      add commands and option inputs
#map commands to handlers
#get_command :: String -> (()IO -> Int)
get_command(){
    local ret=0
    #command map
    # echo "parsing command $@"
    case "$@" in
        #hybrid shortcuts #LBMUCK
        #delegates to option parser
        -l|-b|-m|-u|-c|-k) 
            get_shortcut "$@";;
        #optionless commands
        stats|stat|s)   cmd_stats;;
        ui)             cmd_ui;;
        #simple commands performed 
        #on current repo/branch
        list|ls)        cmd_list;;
        branch|br)      cmd_branch;;
        update|up)      cmd_update;;
        #compound commands with options
        checkin|ci)     cmd_checkin;;
        checkout|co)    cmd_checkout;;
        request|pr)     cmd_request;;
        merge|mr)       cmd_merge;;
        install|in)     cmd_install;;
        clone|cl)       cmd_clone;;
        diff|df)        cmd_diff;;
        #other commands
        debug|d)        cmd_debug;;
        #wrong command
        *)              ret=22
    esac
    _ret=$? #captures last code
    #update return value if needed
    [[ "$_ret" -gt 0 ]] && ret=$_ret
    return $ret
}

get_shortcut(){
    sc=''
    #LBMUCK
    case "$1" in
        -l) sc='cmd_list';;
        -b) sc='cmd_branch';;
        -m) sc='cmd_merge';;
        -u) sc='cmd_update';;
        -c) sc='cmd_checkin';;
        -k) sc='cmd_checkout';;
    esac
    [ -n "$sc" ] && eval $sc || return $?
}
#hybrid shortcuts with no 
#environment dependencies
#get_info :: $@ -> IO()
get_info(){
    case "$@" in 
        h|-h|help) echo "$usage";;
        v|-v|version) kvget version;;
    esac
}

set_option(){
    #TODO: FIX MAYBE
    # `maybe "$1"` && `maybe "$2"` \
    # && kvset "$1" "$2" && \
    # return 0 || return 1
    local ret=14
    [ -n "$3" ] && ret=$3

    echo "setting options $1 to $2"
    if [ -n "$2" ]; then
        kvset "$1" "$2"
        return 0
    else
        return $ret
    fi
}

# set_shortcut_opt(){
#     local ret=0
#     # [[ "$1" == 'true' ]] && set_option "$2" "$4" || ret=$3
#     set_option "$1" "$3" || ret=$2
#     return $ret
# }

clear_options(){
    kvset branch ""
    kvset target ""
    kvset comment ""
    kvset output ""
}

: <<proc0
  ı̴̴̡♔̡
 (•｡̫̜• )͗
|̧̤͡( ̨  )˥̻   
  U͡͡͡U
proc0
main $@

