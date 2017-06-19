
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
    local stat=`git status`
    local code=GENERIC
    if [[ $stat =~ .*modified.* ]]; then
        code=MODIFIED
    elif [[ $stat =~ .*up\-to\-date.* ]]; then
        code=SYNCED      
    elif [[ $stat =~ .*branch\ is\ behind* ]]; then
        code=BEHIND
    elif [[ $stat =~ .*is\ ahead* ]]; then
        code=AHEAD
    else
        code=UNTRACKED
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
#check_env :: IO() -> ERROR_LABEL
check_env(){
    local ret=0
    #clone is an exception that doesn't need a repo
    # [[ "$1" == 'cl' ]] && return 0
    #TODO: refactor to use error codes instead of text
    #check config file
    # [ -f $config -a -s $config ] || return 11
    #check that current dir is a git directory
    git status 2>/dev/null 1>&/dev/null || ret=10
    #check remote connection: TODO use a nuetral command
    # git fetch 2>/dev/null 1>&/dev/null || return 12
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
