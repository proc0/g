cmd_list(){
    local ret=0
    #list git branches and convert to list
    local target=`kvget target`
    local repo_name=''

    if [ -n "$target" ]; then
        repo_name=${target%\/*}
    else
        repo_name=`get_current_repo`
    fi

    if [ -n "$repo_name" ]; then
        # local get_branches=$(fn repo 'git ls-remote --heads $repo;')
        # local branches=$(list $(echo "`$get_branches $repo_name`"))
        local branches=$(list $(echo "`git branch`"))
        #discard branch ids, and format path to just branch name
        local get_paths=$(fn a '[[ $a == *\/* ]]')
        local format_path=$(fn a 'echo "${a##*/}"')
        #lets put it all together
        filter $get_paths "$branches" | map $format_path || ret=$?
    else
        ret=14
    fi

    return $ret
}