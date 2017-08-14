# main :: IO String -> IO ()
main() {
    #intro
    local cmd=$1
    [ -n "$cmd" ] || 
        oops NO_COMMAND
    #info commands have no deps
    [ -n "$(get_info $cmd)" ] &&
        get_info "$cmd" | 
        more && exit 0

    #test environment
    run_cmd "env_ready \"`echo $@`\""

    #main block
    local ret=0
    clear_options
    parse_yml "$CONFIG" 'cfg_' &&
    exec_command "$@" || ret=$?

    #outro - exit if no error
    [ $ret -eq 0 ] && exit 0
    #or get error key and ...
    err_key=`const KEY $ret`
    [ -z "$err_key" ] && 
        err_key=$ret
    #display error message
    oops "$err_key" "$@"
}
#hybrid shortcuts with no 
#environment dependencies
#get_info :: String -> IO ()
get_info(){
    case "$@" in 
        h|-h|help) . $MANUAL && echo "$usage";;
        v|-v|version) echo "$VERSION";;
    esac
}
#exec_command :: String -> IO Int
exec_command(){
    local ret=0 cmd=$1 argv=$@ opts=''
    #split cmd from opts:
    #if removing dash makes no diff
    #then match command; splice opts
    #else match cmd-opt; splice opts
    [[ "${cmd#*\-}" == "$cmd" ]] &&
    opts="${argv#*$cmd[ ]*}" ||
    opts="${argv#*[^-]*$cmd[ ]*}";
    #replace spaces with _
    opts="_${opts// /_}"
    #then remove _ around opt keys:
    local optkeys=${OPTKEYS//:/}
    for s in $(seq 0 ${#optkeys}); do
        local k="-${optkeys:s:1}"
        #find option keys used and 
        #replace _ with spaces
        if [[ $opts =~ _"$k"_ ]]; then
            opts=${opts//_"$k"_/ $k }
        fi     
    done
    #set options then run command
    local options=${opts:1:${#opts}}
    #note: $opts should not be in ""
    #so that getopts works properly
    set_options $options || ret=$? &&
    get_command "$cmd" || ret=$?
    return $ret
}
#TODO : abstract options to config file
#map command options to setters
#set_option :: $@ -> (()IO -> Int)
set_options() {
    local OPTIND=0 ret=0
    # echo "parsing options $*"
    while getopts "$OPTKEYS" key; do
        #get arg value 
        local val="${OPTARG}"       
        case $key in
            #normal options w/ or w/o args
            k|n) set_option 'name' "$val";;
            o) set_option 'output' "$val";;
            t) set_option 'target' "$val";;
            #command shortcuts #LBMUC
            #add option/command here & get_command
            l|b|m|u|c|t|?)
            #set shortcut option values
            case "$key" in
                c) set_option 'comment' "$val";;
                #getopts sets key to : if val=null
                b|*) [[ $key == ':' && $val != 'b' ]] &&
                   val="`get_current_repo`/`get_current_branch`"
                   #do not set default target
                   #for -b with no user value
                   [[ $val == 'b' ]] ||
                   set_option 'target' "$val";;
            esac;;
        esac
        #keep track of err code
        local _ret=$?
        [ $_ret -gt $ret ] &&
        ret=$_ret
    done
    shift "$((OPTIND-1))"
    return $ret
}
#map commands to handlers
#get_command :: 
get_command(){
    local ret=0 cmd=$1 cmd_len=0
    #get command properties list
    parse_yml "$CMD_CONFIG" 'cmd_'
    cmd_len=${#cmd_configure[@]}
    # iterate commands, and access its properties
    while [ $cmd_len -gt 0 -o $cmd_len -eq 0 ]; do
        local idx=$((cmd_len-1))
        if [ $idx -gt 0 -o $idx -eq 0 ]; then
            # parse command properties
            local pair=${cmd_configure[$idx]}
            local cmd_name=$(fst "$pair")
            local cmd_props=($(snd "$pair"))
            local cmd_handler=${cmd_props[0]} \
                cmd_alias=${cmd_props[1]} \
                cmd_shortcut=${cmd_props[2]};
            #match name, alias, or shortcut flag
            if [[ "$cmd" == "$cmd_shortcut" ||
                  "$cmd" == "$cmd_alias" ||
                  "$cmd" == "$cmd_name" ]]; then
                #execute command
                $cmd_handler || ret=$?
            fi
        fi
        #countdown
        cmd_len=$idx
        #keep track of err code
        local _ret=$?
        [ $_ret -gt $ret ] &&
        ret=$_ret
    done
    return $ret
}
