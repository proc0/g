#!/bin/bash
# g -- git shortcut tool 
# author: proc0@github.com
# set -x
#TODO: set debug flag for any cmd
# git config --global alias.ignore 'update-index --skip-worktree'
# git config --global alias.unignore 'update-index --no-skip-worktree'
# git config --global alias.ignored '!git ls-files -v | grep "^S"'
src_dir=`dirname "${BASH_SOURCE[0]}"`
config=$src_dir/config.yml
[ -f $(pwd)/g.conf.yml ] && config=$(pwd)/g.conf.yml
#careful reordering !
. $src_dir/lib/kvbash.sh
. $src_dir/src/lambda.sh 1>/dev/null
. $src_dir/src/globals.sh
. $src_dir/src/commands/index.sh
. $src_dir/src/gui/index.sh
. $src_dir/src/utils/index.sh

#main :: $@ -> IO()
main() {
    [ -n "$1" ] || oops NO_COMMAND
    #info commands have no dep options
    [ -n "$(get_info $1)" ] && get_info "$1" \
    | more && exit 0
    #test environment dependencies
    env_ready "$@"

    #main event
    local ret=0
    clear_options
    parse_config || ret=$? \
    && exec_command "$@" || ret=$?
    #clean exit if zero
    [ $ret -eq 0 ] && exit 0
    #else error code for human :(
    err_key=`const KEY $ret`
    [ -n "$err_key" ] && oops "$err_key" "$@" \
    || oops "$ret" "$@"
}
#exec_command :: $@ -> (()IO -> Int)
exec_command(){
    local ret=0
    local cmd=$1
    local argv=$@
    local opts=''
    #split cmd from opts:
    #if removing dash makes no diff
    #then match command; splice options
    #else match cmd-opt; splice options
    [[ "${cmd#*\-}" == "$cmd" ]] \
    && opts="${argv#*$cmd[ ]*}" \
    || opts="${argv#*[^-]*$cmd[ ]*}"
    #set options then run command
    #note: $opts should not be in quotes
    #so that getopts works properly
    set_options $opts || ret=$? \
    && get_command "$cmd" || ret=$?
    return $ret
}
#map command options to setters
#set_option :: $@ -> (()IO -> Int)
set_options() {
    local OPTIND=0
    local ret=0
    local opt_keys=':hvsl:b:m:u:k:c::n:o:t:d:'
    # echo "parsing options $*"
    while getopts "$opt_keys" key; do
        #get arg value 
        #everything after the space EXCEPT FOR COMMENT
        local val="${OPTARG#* }"
        #set val to empty if value is the shortcut cmd
        #which means no arg value was supplied by user
        [[ "$OPTARG" == "${1#*-}" ]] && val=''        
        case $key in
            #normal options w/ or w/o args
            n) set_option "name"   "$val";;
            o) set_option "output" "$val";;
            t) set_option "target" "$val";;
            #command shortcut option handling #LBMUCK
            #add option/command here & get_command
            l|b|m|u|c|k|?)
                local flag="$key" #shortcut flag
                #when getopts can't parse option, opts=':'
                #check for this to make the switch case handle
                #shortcuts with required options and no options
                [[ $flag == ':' ]] && flag="$1" || flag="-$key"
                #set shortcut option values
                case "$flag" in
                    #pass in everything but the first arg
                    #for comments only
                    -c) set_option 'comment' "${*:2}" || ret=14;;
                    -k) local repo=`get_current_repo` \
                        && set_option 'name' "$val" \
                        && set_option 'target' "$repo";;
                    *)  set_option 'target' "$val";;
                esac
                return $ret;;
            #other options
            d) set_option "_debug" "$val";;
        esac
        ret=$?
        #break on error
        [ $ret -gt 0 ] && break
    done
    [ $ret -eq 0 ] && shift "$((OPTIND-1))"
    return $ret
}
#TODO: read command configuration from
#      yaml file and programmatically
#      add commands and option inputs
#map commands to handlers
#get_command :: String -> (()IO -> Int)
get_command(){
    local ret=0
    local cmd="$@"
    #shortcut map
    case "$1" in
        -l) cmd='ls';;
        -b) cmd='br';;
        -m) cmd='mr';;
        -u) cmd='up';;
        -c) cmd='ci';;
        -k) cmd='co';;
    esac
    #command map
    case $cmd in
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
        config|cf)      cmd_config;;
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
#hybrid shortcuts with no 
#environment dependencies
#get_info :: $@ -> IO()
get_info(){
    . $src_dir/src/manual.sh
    case "$@" in 
        h|-h|help) echo "$usage";;
        v|-v|version) kvget version;;
    esac
}
# set_option :: Key -> Value -> ErrorCode -> IO()
set_option(){
    [ -z "$2" ] && return 14 #no option value!
    # echo "setting option $1 to $2"
    kvset "$1" "${*:2}"
}
# clear_options :: () -> IO()
clear_options(){
    #TODO: abstract to some option config
    kvset branch ""
    kvset target ""
    kvset comment ""
    kvset output ""
    kvset name ""
}

: <<proc0
       _,.---'---.,_
    ,-~             ~-.
  ,^                   ^.
 /                       \
(                         )
|  ~"---\         /---"~  |
\ ( .--.. ~" . "~ .--.. ) / 
 ( (     '-. I ,-'     ) )
 ] ! .#@.  / | \  .@#. ! [
.- (::,.--" .^. "--.,::) -.
(      ~    /|\     ~     )
 \.__,T  "  V"V  "  T.__,/
      )             (
      [. : :.:.: : .]
      ''-:,(_|_),:-''
proc0
main $@

