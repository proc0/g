cmd_checkout(){
    local target=`kvget target`
    local name=`kvget name`
    local ret=0

    if [ -n "$name" ]; then
        if [[ $name =~ \/{1} ]]; then
            local repo="${name%\/*}"
            local branch="${name#*\/}"
            # echo "br: $branch, rp: $repo"
            git checkout -b "$branch"
            git push -u "$repo" "$branch"
        else
            # echo "no name br: $name, rp: $target"
            git checkout -b "$name"
            git push -u "$target" "$name"
        fi
    else
        name="`get_current_branch`_$(date +%s)"
        git checkout -b "$name"
        git push -u "$target" "$name"
    fi
    cmd_status
    return $ret
}