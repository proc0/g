cmd_request(){
    local ret=0
    local repo=`get_current_repo`
    local branch=`get_current_branch`
    local remote_target=`kvget target`
    #TODO: get name of remote repo
    local remote_repo_name=`get_remote_repo_name`
    local url="https://git.autodesk.com/$remote_repo_name/ui/compare/$remote_target...$remote_repo_name:$branch?expand=1"
    echo "Opening $url..."
    #TODO: outsource this to config to open with w/e
    open -a "/Applications/Google Chrome.app" "$url" || ret=$?
    return $ret
}