
parse_config(){
    #load config file
    # echo "using config: $config"

    eval $(parse_yaml $config)
    # repo="${repos[0]% : *}"
    # url="${repos[0]#* : }"
    # echo $url
    # echo "$targets_default"
    # for i in ${remotes[@]}; do
    #     local repo="`printf ${remotes[$i]% : *}`"
    #     # local url="${remotes[$i]#* : }"
    #     printf "using ${repo}"
    #     # echo 'blah'"`echo ${remotes[i]}`'blah'
    # done
    # printf "${remotes[@]}"
}

get_status(){
    echo "`const STS $(get_status_code)`"
}

: <<blah
' ' = unmodified

M = modified

A = added

D = deleted

R = renamed

C = copied

U = updated but unmerged

Ignored files are not listed, unless --ignored option is in effect, in which case XY are !!.

X          Y     Meaning
-------------------------------------------------
          [MD]   not updated
M        [ MD]   updated in index
A        [ MD]   added to index
D         [ M]   deleted from index
R        [ MD]   renamed in index
C        [ MD]   copied in index
[MARC]           index and work tree matches
[ MARC]     M    work tree changed since index
[ MARC]     D    deleted in work tree
-------------------------------------------------
D           D    unmerged, both deleted
A           U    unmerged, added by us
U           D    unmerged, deleted by them
U           A    unmerged, added by them
D           U    unmerged, deleted by us
A           A    unmerged, both added
U           U    unmerged, both modified
-------------------------------------------------
?           ?    untracked
!           !    ignored
-------------------------------------------------
blah

get_status_code(){
    #TODO fix status codes and allow multiple codes
    local stat=`git status`
    local code=GENERIC

    local isDetached=`echo $stat | grep 'HEAD detached'`
    [ -n "$isDetached" ] && code=DETACHED && echo "$code"

    if [[ $stat =~ .*modified.* ]]; then
        code=MODIFIED
    elif [[ $stat =~ .*up\-to\-date.* || $stat =~ .*nothing\ to\ commit.* ]]; then
        local untracked=`echo $stat | grep 'Untracked\ files'`
        code=SYNCED
        [ -n "$untracked" ] && code=UNTRACKED
    elif [[ $stat =~ .*branch\ is\ behind* ]]; then
        code=BEHIND
    elif [[ $stat =~ .*is\ ahead* ]]; then
        code=AHEAD
    elif [[ $stat =~ .*Untracked.* ]]; then
        code=UNTRACKED
    else
        code=UNKNOWN
    fi
    echo "$code"
}

get_current_branch(){
    git branch --list | \
    grep -E -o '\*.*' | \
    sed -e 's/\* \(.*\)/\1/g'
}

get_current_repo(){
    local repo_name=`git branch -vv | \
        grep -E -o '\*.*\[.*\]' | \
        sed -e 's/\*.*\[\(.*\)\/\(.*\)\]/\1/g'`
    #if git adds remote/ to the name
    if [[ $repo_name =~ remotes\/ ]]; then
        repo_name=`cut -d '/' -f 2 <<< $repo_name`
    fi
    echo "$repo_name"
}
#check command hard dependencies
#check_env :: IO() -> ERROR_LABEL
check_env(){
    local ret=0
    #TODO consolidate status 
    #check with get_status
    local _stat=`get_status`
    #exceptions - no environment needed
    [[ "$1" == 'cl' ]] && return 0
    #check config file
    ([ -e "$config" ] || ret=11) && \
    #check that current dir is a git directory
    (git status 2>/dev/null 1>&/dev/null || ret=10) && \
    #check remote connection: TODO use a nuetral command
    (git fetch 2>/dev/null 1>&/dev/null ||  ret=12) && \
    #HEAD is detached
    [[ "$_stat" == 'DETACHED' ]] && ret=0
    return $ret
}

env_ready(){
    local err_code=0
    check_env || err_code=$?

    [ $err_code -gt 0 ] && oops "$err_code" "$@"

    return 0
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

rem_cache=""
check_remote(){
    local rem_list
    local rem_name=$1
    #cach git remote show to avoid multiple calls
    [ -n "$rem_cache" ] && rem_list=$rem_cache \
    || rem_cache=`get_remotes` && rem_list=(`echo "$rem_cache"`)

    local exists=1 #1 is FALSE
    local rem_len=${#rem_list[@]}
    #iterate through git remotes and check names
    while [ $rem_len -gt 0 -a $exists -eq 1 ]; do
        local idx=$((rem_len-1))
        if [ $idx -gt 0 -o $idx -eq 0 ]; then 
            local rem_i=${rem_list[$idx]}
            if [[ "$rem_name" == "$rem_i" ]]; then
                exists=0 #0 is TRUE
            fi
        fi
        rem_len=$idx
    done
    return $exists
}

get_remotes(){
    local rems=""
    for i in `git remote show`; do 
        rems="$rems $i"
    done
    echo $rems
}

get_username(){
    local user=`git config --global user.name`
    echo $user
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
