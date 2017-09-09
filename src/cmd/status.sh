cmd_status(){
    if [[ 2 -gt `get_git_version` ]]; then
        cmd_status_v1
    else
        cmd_status_v2
    fi

}

cmd_status_v1(){
    git status --branch --untracked --long --porcelain
}

cmd_status_v2(){
    git status --branch --untracked --long --porcelain=v2
}
