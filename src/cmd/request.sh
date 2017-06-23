cmd_request(){
    local ret=0
    local repo=`get_current_repo`
    local branch=`get_current_branch`
    local remote_target=`kvget target`
    local message=`kvget comment`
    local user=`get_username`

    local msg_title='' msg_body=''

    [[ "$message" =~ \n ]] \
    && msg_title="${message%\n*}" \
    && msg_body="${message#*\n}"

    [[ "$message" =~ \{body\} ]] \
    && msg_title="${message%\{body\}*}" \
    && msg_body="${message#*\{body\}}" \


    ([ -z "$remote_target" -o -z "$msg_title" -o -z "$msg_body" ]) \
    && return 14 #no argval

    echo "title:$msg_title, body:$msg_body, head:$user:$branch, base:$remote_target"
    #TODO: get name of remote repo
    # local remote_repo_name=`get_remote_repo_name`


    # local url="https://git.autodesk.com/$remote_repo_name/ui/compare/$remote_target...$remote_repo_name:$branch?expand=1"
    # echo "Opening $url..."
    #TODO: outsource this to config to open with w/e
    # open -a "/Applications/Google Chrome.app" "$url" || ret=$?

    # curl -H "Content-Type: application/json" -X POST -d '{"username":"xyz","password":"xyz"}' https://git.autodesk.com/repos/

    return $ret
}
