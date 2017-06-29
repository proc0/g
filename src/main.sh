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
    parse_yml "$config" 'cfg_' && \
    exec_command "$@" || ret=$?
    #clean exit if zero
    [ $ret -eq 0 ] && exit 0
    #or err code for human :(
    err_key=`const KEY $ret`
    [ -z "$err_key" ] && err_key=$ret
    oops "$err_key" "$@"
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
#exec_command :: $@ -> (()IO -> Int)
exec_command(){
    local ret=0 cmd=$1 argv=$@ opts=''
    #split cmd from opts:
    #if removing dash makes no diff
    #then match command; splice opts
    #else match cmd-opt; splice opts
    [[ "${cmd#*\-}" == "$cmd" ]] \
    && opts="${argv#*$cmd[ ]*}" \
    || opts="${argv#*[^-]*$cmd[ ]*}"
    #replace spaces with underscores
    local optkeys=${OPTKEYS//:/}
    opts="_${opts// /_}"
    #remove _ surrounding opt keys
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
    (set_options $options) || ret=$? \
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
            #normal options w/ or w/o args
            k|n) set_option 'name' "$val";;
            o) set_option 'output' "$val";;
            t) set_option 'target' "$val";;
            #command shortcuts #LBMUC
            #add option/command here & get_command
            l|b|m|u|c|t|?)
            #set shortcut option values
            case "$key" in
                #pass in everything but the first arg
                #for comments only
                c) set_option 'comment' "$val";;
                #getopts sets key to : if val=null
                b|*) [[ $key == ':' && $val != 'b' ]] && \
                   local repo=`get_current_repo` && \
                   local branch=`get_current_branch` && \
                   val="$repo/$branch"
                   #do not set default target
                   #for -b with no user value
                   [[ $val == 'b' ]] || \
                   set_option 'target' "$val";;
            esac;;
        esac
        #keep track of err code
        local _ret=$? && \
        [ $_ret -gt $ret ] && \
        ret=$_ret
    done
    shift "$((OPTIND-1))"
    return $ret
}
#map commands to handlers
#get_command :: 
get_command(){
    local ret=0 cmd="$1" cmd_len=0
    #get command properties list
    parse_yml "$cmd_config" 'cmd_'
    cmd_len=${#cmd_configure[@]}
    while [ $cmd_len -gt 0 -o $cmd_len -eq 0 ]; do
        local idx=$((cmd_len-1))
        if [ $idx -gt 0 -o $idx -eq 0 ]; then
            local pair=${cmd_configure[$idx]} \
                #split pair into 1st and 2nd field w/ cut
                cmd_name=$(echo `cut -d ':' -f 1 <<<"$pair"`) \
                #note: 2nd field may contain delim (in url)
                cmd_props=($(echo `cut -d ':' -f 2 <<<"$pair"`)) \
                #example url=$(echo `cut -d ':' -f 2,3,4 <<< $pair`)
                cmd_handler=${cmd_props[0]} \
                cmd_alias=${cmd_props[1]} \
                cmd_shortcut=${cmd_props[2]};
            #match name, alias, or shortcut flag
            if [[ "$cmd" == "$cmd_shortcut" || \
                  "$cmd" == "$cmd_alias" || \
                  "$cmd" == "$cmd_name" ]]; then
                $cmd_handler || ret=$?
            fi
        fi
        #countdown
        cmd_len=$idx
        #keep track of err code
        local _ret=$? && \
        [ $_ret -gt $ret ] && \
        ret=$_ret
    done
    return $ret
}
