cmd_request(){
    local ret=0
    local message=`kvget comment`
    local remote_target=`kvget target`
    local user=`get_username`
    local branch=`get_current_branch`
    local repo=`get_remote_repo_name $(get_current_repo)`

    local msg_title='' msg_body=''

    [[ "$message" =~ \n ]] \
    && msg_title="${message%\n*}" \
    && msg_body="${message#*\n}"

    [[ "$message" =~ \{body\} ]] \
    && msg_title="${message%\{body\}*}" \
    && msg_body="${message#*\{body\}}" \

    ([ -z "$remote_target" -o -z "$msg_title" -o -z "$msg_body" ]) \
    && return 14 #no argval

    # echo "title:$msg_title 
    #       body:$msg_body
    #       head:$branch
    #       base:$repo
    #       url:$repo/pulls"

    #github API call
    response=`curl -v \
    -u "$user:ee693db1978cc7792f1881b3433dde25fa384f25" \
    -H "Content-Type: application/json" \
    -H "Authorization: token ee693db1978cc7792f1881b3433dde25fa384f25" \
    -X POST -d "{\"title\":\"$msg_title\",\"head\":\"$branch\",\"base\":\"$remote_target\",\"body\":\"$msg_body\"}" \
    "https://git.autodesk.com/api/v3/repos/$repo/pulls"`

    _ret=$?
    [ $_ret -gt 0 ] && ret=$_ret

    if [ -n "$response" ]; then
        #get _links.self which has one entry - html: url
        local self_url=($(echo `awk -v var="$response" 'c&&!--c;/.*self.*":/{c=1}'`))
        local url=${self_url#*:}

        echo "Opening url: $url"
        # open -a "/Applications/Google Chrome.app" "$url" || ret=$?
    fi

    return $ret
}

get_remote_repo_name(){
    local repo_url=`git config --get remote.$1.url`
    local repo_name=`dirname $repo_url | sed -e 's/.*\/\(.*\)/\1/'`
    local repo_main=`echo ${repo_url##*/} | sed -e 's/\(.*\).git/\1/'`

    echo "$repo_name/$repo_main"
}
