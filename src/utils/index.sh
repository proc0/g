
parse_config(){
    #load config file
    eval $(parse_yaml $config)
    repo="${repos[0]% : *}"
    url="${repos[0]#* : }"
    # echo $url
    # echo "$targets_default"
}

get_status(){
    echo "`const STS $(get_status_code)`"
}

get_status_code(){
    stat=`git status`
    code=GENERIC
    if [[ $stat =~ .*modified.* ]]; then
        code=MODIFIED
    elif [[ $stat =~ .*up\-to\-date.* ]]; then
        code=SYNCED      
    elif [[ $stat =~ .*branch\ is\ behind* ]]; then
        code=BEHIND
    elif [[ $stat =~ .*is\ ahead* ]]; then
        code=AHEAD
    fi
    echo "$code"
}

get_current_branch(){
    git branch --list | \
    grep -E -o '\*.*' | \
    sed -e 's/\* \(.*\)/\1/g'
}

get_current_repo(){
    git branch -vv | \
    grep -E -o '\*.*\[.*\]' | \
    sed -e 's/\*.*\[\(.*\)\/\(.*\)\]/\1/g'
}
#check command hard dependencies
#env_ready :: IO() -> ERROR_LABEL
env_ready(){
    [[ "$1" == 'cl' ]] && return 0
    #TODO: refactor to use error codes instead of text
    #check config file
    ([ -f $config -a -s $config ] && echo "" || echo "NO_CONFIG") &&
    #check that current dir is a git directory
    (git status 2>/dev/null 1>&/dev/null && echo "" || echo "NO_GIT") ||
    #check remote connection: TODO use a nuetral command
    (git fetch 2>/dev/null 1>&/dev/null && echo "" || echo "NO_CONNECTION")
}

lift_IFS(){
    _ifs=$IFS
    if [ -n "$1" ]; then
        export IFS="$1"
    elif [ -n "$_ifs" ]; then
        export IFS=$_ifs
    else
        unset IFS
    fi
}

parse_yaml() {
    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
        }
    }' | sed 's/_=/+=/g'
}
