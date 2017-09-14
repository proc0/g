# main :: Command -> IO Int
main() {
    local ret=0 cmd=$1 opts="-$@" 
    [ -n "$cmd" ] || oops NO_CMD
    
    # gitless commands
    [ -n "$(show_info $cmd)" ] &&
        show_info "$cmd" | 
            more && exit 0

    # check runtime dependencies
    safe_run "envtest \"`echo $@`\""
    # 
    clear_options
    parse_yml "$CONFIG" 'cfg_' &&
    parse_options `escape_opts "$opts"` &&
    parse_command "$cmd" || ret=$?

    # exit if no error
    [ $ret -eq 0 ] && exit 0
    # or get error key, and
    err_key=`const KEY $ret`
    [ -z "$err_key" ] && 
        err_key=$ret
    # display error message
    oops "$err_key" "$@"
}

# show_info :: Command -> IO Int
show_info(){
    case "$@" in 
        h|-h|help) . $MANUAL && 
            echo "$usage";;
        v|-v|version) echo "$VERSION";;
    esac
}

# parse_options :: SafeOptions -> IO Int
parse_options() {
    local OPTIND=0 ret=0
    # echo "parsing options $*"
    while getopts "$OPTKEYS" key; do
        local val=${OPTARG}
        # to avoid ret=1 ...
        # check for true cond
        # instead of -n $val      
        [ -z "$val" ] || 
        set_option "$key" "$val"
        # keep track of fun code
        local _ret=$?
        [ $_ret -gt $ret ] &&
        ret=$_ret
    done
    shift "$((OPTIND-1))"
    return $ret
}

# parse_command :: Command -> IO Int
parse_command(){
    local ret=0 cmd=$1 cmd_len=0
    # get command list
    parse_yml "$CMD_CONFIG" 'cmd_'
    cmd_len=${#cmd_settings[@]}
    # iterate and configure commands
    while [ $cmd_len -gt 0 -o $cmd_len -eq 0 ]; do
        local idx=$((cmd_len-1))
        if [ $idx -gt 0 -o $idx -eq 0 ]; then
            # parse command properties
            local pair=${cmd_settings[$idx]}
            local cmd_name=$(fst "$pair")
            local cmd_props=($(snd "$pair"))
            local cmd_subr="cmd_$cmd_name" \
                  cmd_alias=${cmd_props[0]} \
                  cmd_arg1key=${cmd_props[1]} \
                  cmd_arg2flag=${cmd_props[2]} \
                  cmd_arg2key=${cmd_props[3]};

            # match name or alias
            if [[ "$cmd" == "$cmd_alias" ||
                  "$cmd" == "$cmd_name" ]]; then                  
                # transfer option values
                if [ -n "$cmd_arg1key" ]; then
                    # primary option value
                    if [ -n "$cmd_alias" -a \
                         -n "$cmd_arg1key" ]; then
                        local cmd_arg1val=`kvget "$cmd_alias"`
                        kvset "$cmd_arg1key" "$cmd_arg1val"
                    fi
                    # secondary option value
                    if [ -n "$cmd_arg2flag" ]; then
                        local cmd_arg2val=`kvget "$cmd_arg2flag"`
                        kvset "$cmd_arg2key" "$cmd_arg2val"
                    fi
                fi
                # execute command
                $cmd_subr || ret=$?
            fi
        fi
        # countdown
        cmd_len=$idx
        # fun code
        local _ret=$?
        [ $_ret -gt $ret ] &&
        ret=$_ret
    done
    return $ret
}
