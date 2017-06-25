cmd_checkout(){
    set -x
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
                # echo "no name br: $name, rp: $target"
                git checkout -b "$name"
                git push -u "$t_repo" "$t_branch"
            fi
        else
            name="$t_branch_$(date +%s)"
            git checkout -b "$name"
            git push -u "$t_repo" "$t_branch"
        fi
    fi
    cmd_status
    return $ret
}