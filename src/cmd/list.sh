cmd_list(){
    local branch_list="`cmd_list_branches`"
    echo "${branch_list// /$'\n'}"
}

cmd_list_branches(){
    local ret=0
    local repo_name=''
    local _source=`kvget "source"`
    local _source2="$1"


    if [ -n "$_source2" ]; then
        repo_name="$_source2"
    elif [ -n "$_source" ]; then
        if [[ $_source =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
            repo_name=${_source%\/*}
        else
            repo_name=$_source
        fi         
    else
        repo_name=`get_current_repo`
    fi

    if [ -n "$repo_name" ]; then
        local branches=`get_branches $repo_name`
        local branch_names="`_filter 'get_branch_names' "$branches"`"
        local branch_list="`_map 'format_path' "$branch_names"`"
        echo $branch_list
    else
        ret=14
    fi

    return $ret
}

get_branches(){
    local repo_name=$1
    echo "`git ls-remote --heads $repo_name | awk -F ' ' '{print $2}'`"
}

get_branch_names(){
    local a=$1
    [[ $a == *\/* ]] &&
    return 0 || return 1å
}

format_path(){
    local a=$1
    echo "${a##*/}"
}
