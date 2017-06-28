cmd_request(){
    local ret=0
    local msg=`kvget comment`
    local target=`kvget target`
    local user=`get_username`
    local repo=`get_remote_repo_name`
    local branch=`get_current_branch`
    local domain=`get_remote_base_url`

    local post_url="$domain/api/v3/repos/$repo/pulls";

    local base=''
    #TODO: cross repo pull requests
    if [ -n "$target" ]; then 
        if [[ $target =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
            t_branch=${target#*/}
            # t_repo=${target%/*}
        else
            t_branch=$target
            # t_repo=`get_current_repo`
        fi
        base=$t_branch
    fi

    #break up message into title and body
    local msg_title='' msg_body=''
    [[ "$msg" =~ \{body\} ]] &&
    msg_title="${msg%\{body\}*}" &&
    msg_body="${msg#*\{body\}}"
    
    #check arguments
    ([ -z "$branch" -o \
       -z "$base" -o \
       -z "$msg_title" -o \
       -z "$msg_body" ]) &&
    [[ $post_url =~ https:\/\/ ]] &&
    [[ $post_url =~ [^https:]\/\/ ]] &&
    return 14 #bad option values

    #payload example
    echo "Raising pull request...
    title: $msg_title 
    body: $msg_body
    head: $branch
    base: $base
    url: $post_url"

    #github API call
    local response=`curl -v \
        -u "$user:${cfg_access_token}" \
        -H "Content-Type: application/json" \
        -H "Authorization: token ${cfg_access_token}" \
        -X POST -d "{ \
            \"title\":\"$msg_title\", \
            \"head\":\"$branch\", \
            \"base\":\"$base\", \
            \"body\":\"$msg_body\" \
            }" \
        "$post_url"`

    local _ret=$?
    [ $_ret -gt 0 ] && ret=$_ret

    #parse JSON to get PR url
    if [ -n "$response" ]; then
        #TODO: parse JSON without dependencies
        local self_url=`echo "$response" | python -c "import json,sys;obj=json.load(sys.stdin);print obj['_links']['self']['href'];"`
        local pr_num=`echo ${self_url##*/} | sed -e 's/\([0-9]+\)/\1/'`
        #github url for this pr
        local pr_url="$domain/$repo/pull/$pr_num"
        
        echo "$pr_url"
        open -a "/Applications/Google Chrome.app" "$pr_url" || ret=$?
    fi

    return $ret
}

get_remote_repo_name(){
    local repo_url=`get_remote_url`
    local repo_name=`dirname "$repo_url" | sed -e 's/.*\/\(.*\)/\1/'` \
        repo_main=`echo ${repo_url##*/} | sed -e 's/\(.*\).git/\1/'`;
    echo "$repo_name/$repo_main"
}

get_remote_base_url(){
    local repo_url=`get_remote_url`
    #regex match only https://domain.com
    echo "`sed -e 's/\(https:\/\/\)\([^\/]*\)\(.*\)/\1\2/g' <<<"$repo_url"`"
}

get_remote_url(){
    local repo_label=`get_current_repo` \ 
        repo_url=`git config --get remote.$repo_label.url`;
    echo "$repo_url" 
}

