cmd_request(){
    local ret=0
        msg=`kvget comment` \
        base=`kvget target` \
        user=`get_username` \
        repo=`get_remote_repo_name` \
        branch=`get_current_branch` \
        domain=`get_remote_base_url` \
        post_url="$domain/api/v3/repos/$repo/pulls";

    #break up message into title and body
    local msg_title='' msg_body=''
    [[ "$msg" =~ \{body\} ]] \
    && msg_title="${msg%\{body\}*}" \
    && msg_body="${msg#*\{body\}}" \
    
    #check arguments
    ([ -z "$branch" -o \
       -z "$base" -o \
       -z "$msg_title" -o \
       -z "$msg_body" ]) \
    && [[ $post_url =~ https:\/\/ ]] \
    && [[ $post_url =~ [^repos\/\/] ]] \
    && return 14 #bad option values

    #payload example
    echo "Raising pull request...
    title: $msg_title 
    body: $msg_body
    head: $branch
    base: $base
    url: $post_url"

    #github API call
    local response=`curl -v \
        -u "$user:${access_token}" \
        -H "Content-Type: application/json" \
        -H "Authorization: token ${access_token}" \
        -X POST -d "{ \
            \"title\":\"$msg_title\", \
            \"head\":\"$branch\", \
            \"base\":\"$base\", \
            \"body\":\"$msg_body\" \
            }" \
        "$post_url"`

    local _ret=$?
    [ $_ret -gt 0 ] && ret=$_ret
    #open github pr url
    if [ -n "$response" ]; then
        #get _links.self which has one entry - html: url
        # local self_url=($(echo `awk -v var="$response" 'c&&!--c;/.*self.*:/{c=1}'`))
        # local url=`sed -e 's/\(https:\/\/\)\([^\/]*\)\(.*\)/\1\2\3/g' <<<$self_url`

        echo "$response"
        # open -a "/Applications/Google Chrome.app" "$url" || ret=$?
    fi

    return $ret
}

get_remote_repo_name(){
    local repo_url=`get_remote_url` \
        repo_name=`dirname $repo_url | sed -e 's/.*\/\(.*\)/\1/'` \
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

