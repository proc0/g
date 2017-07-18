cmd_list(){
    local ret=0
    local repo_name=''
    local target=`kvget target`
    if [ -n "$target" ]; then
        if [[ $target =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
            repo_name=${target%\/*}
        else
            repo_name=$target
        fi           
    else
        repo_name=`get_current_repo`
    fi

    if [ -n "$repo_name" ]; then
        local branches=`get_branches $repo_name`
        local branch_list="`_filter 'get_paths' "$branches"`"
        local display_list="`_map 'format_path' "$branch_list"`"
        echo $display_list
    else
        ret=14
    fi

    return $ret
}

get_branches(){
    local repo_name=$1

    echo "`git ls-remote --heads $repo_name | awk -F ' ' '{print $2}'`"
}

get_paths(){
    local a=$1
    [[ $a == *\/* ]] &&
    return 0 || return 1
}

format_path(){
    local a=$1
    echo "${a##*/}"
}
