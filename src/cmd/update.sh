cmd_update(){
    local ret=0
    local repo_len=${#cfg_remotes[@]}
    #update cfg_remotes if cfg_remotes exists
    while [ $repo_len -gt 0 -o $repo_len -eq 0 ]; do
        local idx=$((repo_len-1))
        if [ $idx -gt 0 -o $idx -eq 0 ]; then
            local pair=${cfg_remotes[$idx]}
            #split pair into 1st and 2nd field w/ cut
            #note: 2nd field may contain delim (in url)
            #local url=$(echo `cut -d ':' -f 2,3,4 <<< $pair`)
            local repo=$(echo `cut -d ':' -f 1 <<< $pair`)
            check_remote "$repo"
            #check return code to
            #prevent it from propagating
            if [ $? -eq 0 ]; then
                echo -e "updating $repo ..."
                git fetch "$repo" || ret=$?
            fi
        fi
        #countdown
        repo_len=$idx
    done
    local _ret=$?
    [[ "$_ret" -gt 0 ]] && return $_ret
    [[ "$ret" -gt 0 ]] && return $ret
    cmd_status
    return 0
}