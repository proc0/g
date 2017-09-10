cmd_branch(){
    local ret=0
    local stat_code=`get_status_code`

    if [ -n "$stat_code" ];then
        echo 'Commit or stash changes first.'
    else
        local target=`kvget target`

        if [ -n "$target" ]; then
            if [[ $target =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
                local repo="${target%\/*}"
                local branch="${target#*\/}"
                git checkout -b "$branch"
                git push -u "$repo" "$branch"
            else
                local repo=`get_current_repo`                
                git checkout -b "$target"
                git push -u "$repo" "$target"
            fi
        fi
    fi
    cmd_status
    return $ret
}
