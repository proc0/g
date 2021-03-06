cmd_status(){
    if [[ 3 -gt `get_git_version` ]]; then
        cmd_status_v1
    else
        cmd_status_v2
    fi

}

cmd_status_v1(){
    git status --branch --untracked --porcelain
}

cmd_status_v2(){
    git status --branch --untracked --porcelain=v2 -s
}
