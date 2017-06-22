cmd_checkin(){
    local ret=0

    local msg=`kvget comment`
    local status_code=`get_status_code`
    #no comment value
    [ -z "$msg" ] && ret=14

    if [[ "$status_code" == 'SYNCED' ]]; then
        echo "`const TXT UP_TO_DATE`"
    elif [[ "$status_code" == 'UNTRACKED' ]]; then
        return 99
    elif [[ "$status_code" == 'AHEAD' ]]; then
        git push "`get_current_repo`" "`get_current_branch`"
        cmd_status        
    elif [ -n "$msg" ]; then
        git add -A .
        git commit -m "$msg" || ret=$?
        git push "`get_current_repo`" "`get_current_branch`"
        cmd_status
    fi
     _ret=$? #update ret if needed
    [ $_ret -gt 0 ] && ret=$_ret
    return $ret
}
