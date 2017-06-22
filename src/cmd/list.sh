cmd_list(){
    local ret=0
    #list git branches and convert to list
    local target=$(kvget target || get_current_repo)
    local get_branches=$(fn repo 'git ls-remote --heads $repo;')
    local branches=$(list $(echo "`$get_branches $target`"))
    #discard branch ids, and format path to just branch name
    local get_paths=$(fn a '[[ $a == *\/* ]]')
    local format_path=$(fn a 'echo "${a##*/}"')
    #lets put it all together
    filter $get_paths "$branches" | map $format_path || ret=$?
    return $ret
}