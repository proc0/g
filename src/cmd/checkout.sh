cmd_checkout(){
    local ret=0
    local stat_code=`get_status_code`

    if [[ "$stat_code" == 'MODIFIED' ]];then
        echo 'Commit or stash changes first.'
    else
        local target=`kvget target`
        local name=`kvget name`
        local t_branch='' t_repo=''

        if [ -n "$target" ]; then 
            if [[ $target =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
                t_branch=${target#*\/}
                t_repo=${target%\/*}
            else
                t_branch=$target
                t_repo=`get_current_repo`
            fi
        fi

        if [ -n "$name" ]; then
            if [[ $name =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
                local repo="${name%\/*}"
                local branch="${name#*\/}"
                # echo "br: $branch, rp: $repo"
                git checkout -b "$branch"
                git push -u "$repo" "$branch"
            else
                t_repo=`get_current_repo`                
                # echo "no name br: $name, rp: $target"
                git checkout -b "$name"
                git push -u "$t_repo" "$name"
            fi
        fi
    fi
    cmd_status
    return $ret
}
