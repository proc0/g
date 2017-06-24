. $src_dir/src/cmd/index.sh
#main :: $@ -> IO()
main() {
    local cmd=$1
    [ -n "$cmd" ] || oops NO_COMMAND
    #info commands have no dep options
    [ -n "$(get_info $cmd)" ] && \
    get_info "$cmd" | more && \
    exit 0
    #test environment
    env_ready "$@"
    #main event
    local ret=0
    clear_options
    parse_config || ret=$? && \
    exec_command "$@" || ret=$?
    #clean exit if zero
    [ $ret -eq 0 ] && exit 0
    #or err code for human :(
    err_key=`const KEY $ret`
    [ -z "$err_key" ] && err_key=$ret
    oops "$err_key" "$@"
}
#exec_command :: $@ -> (()IO -> Int)
exec_command(){
    local ret=0 cmd=$1 argv=$@ opts=''
    #split cmd from opts:
    #if removing dash makes no diff
    #then match command; splice options
    #else match cmd-opt; splice options
    [[ "${cmd#*\-}" == "$cmd" ]] \
    && opts="${argv#*$cmd[ ]*}" \
    || opts="${argv#*[^-]*$cmd[ ]*}"
    #replace spaces with underscores
    local optlist="${OPTKEYS//:/ |-}"
    opts=${opts//[^$optlist\s] [^$optlist\s]/_}
    # opts=${opts//[^-hvslbmukcnotd\s] [^-hvslbmukcnotd\s]/_}
    
    #set options then run command
    #note: $opts should not be in ""
    #so that getopts works properly
    (set_options $opts) || ret=$? \
    && get_command "$cmd" || ret=$?
    return $ret
}
#map command options to setters
#set_option :: $@ -> (()IO -> Int)
set_options() {
    local OPTIND=0 ret=0
    # echo "parsing options $*"
    while getopts "$OPTKEYS" key; do
        #get arg value 
        local val="${OPTARG}"       
        case $key in
            #command shortcuts #LBMUCK
            #add option/command here & get_command
            l|b|m|u|c|k|?)
                #set shortcut option values
                case "$key" in
                    #pass in everything but the first arg
                    #for comments only
                    c) set_option 'comment' "$val" || ret=14;;
                    k) local repo=`get_current_repo` && \
                       set_option 'name' "$val" && \
                       set_option 'target' "$repo";;
                       #getopts sets key to : if val=null
                    *) [[ $key == ':' ]] && \
                       local repo=`get_current_repo` && \
                       local branch=`get_current_branch` && \
                       val="$repo/$branch";
                       set_option 'target' "$val";;
                esac;;
                # return $ret;;
            #normal options w/ or w/o args
            n) set_option 'name'   "$val";;
            o) set_option 'output' "$val";;
            t) set_option 'target' "$val";;
            d) set -x;;
        esac
        _ret=$?
        #keep track of error code
        [ $_ret -gt $ret ] && ret=$_ret
    done
    shift "$((OPTIND-1))"
    return $ret
}
#TODO: read command configuration from
#      yaml file and programmatically
#      add commands and option inputs
#map commands to handlers
#get_command :: String -> (()IO -> Int)
get_command(){
    local ret=0 cmd="$@"
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
        stats|stat|s)   cmd_status;;
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
        #wrong command
        *) ret=22
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
    . $src_dir/src/doc/manual.sh
    case "$@" in 
        h|-h|help) echo "$usage";;
        v|-v|version) echo "$VERSION";;
    esac
}
# set_option :: Key -> Value -> ErrorCode -> IO()
set_option(){
    local ret=0
    local val="$2"
    [ -z "$val" ] && ret=14 #no option value!
    # echo "setting option $1 to $2"
    # kvset "$1" "${val// /_}"
    #replace underscores with spaces
    kvset "$1" "${val//_/ }"
    return $ret
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
