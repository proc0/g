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
        # local get_branches=$(fn repo 'git ls-remote --heads $repo;')
        local get_branches=$(fn repo 'git ls-remote --heads $repo;')
        local branches=$(list $(echo "`$get_branches $repo_name`"))
        # local br=`git branch` branches=$(list $br)
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
