cmd_stats(){
echo -e "
${GREEN}`get_current_repo`/`get_current_branch` | `get_status`
─────────────────────────────────────────────${NONE}"
}

#cmd_list :: () -> String
cmd_list(){
    local ret=0
    #list git branches and convert to list
    get_branches=$(fn repo 'git ls-remote --heads $repo;')
    branches=$(list $(echo "`$get_branches $(kvget target || get_current_repo)`"))
    #discard branch ids, and format path to just branch name
    get_paths=$(fn a '[[ $a == *\/* ]]')
    format_path=$(fn a 'echo "${a##*/}"')
    #lets put it all together
    filter $get_paths $branches | map $format_path || ret=$?
    return $ret
}

cmd_branch(){
    local ret=0
    input_branch=`kvget target`
    if [ -n "$input_branch" ]; then
        (git checkout "$input_branch" || ret=$?) &&
        (git pull `get_current_repo` "$input_branch" || ret=$?)
    else
        echo -ne "⌛  fetching branch list..." &&
        list_branches || ret=$?
    fi
    return $ret
}

cmd_merge(){
    #TODO: check if conflicts, offer user to revert
    # cmd_revert="git revert -m 1 [sha_of_C9]"
    cur_repo=`get_current_repo`
    cur_branch=`get_current_branch`
    target="$cur_repo/$cur_branch"
    if [ -n "$target" ]; then
        git merge $target
    fi
    cmd_stats
}

cmd_update(){
    echo -e "⌛  fetching remote data..."
    local repo_list=$(list `kvget repos`)
    map $(fn a 'echo \"updating $a...\" && git fetch $a') $repo_list
    cmd_stats
}

cmd_checkin(){
    local msg=`kvget comment`
    local ret=0
    if [ -z "$msg" ]; then
        #no comment value
        ret=14
    elif [[ `get_status_code` == 'SYNCED' ]]; then
        echo 'Already up to date.'
    else
        git add -A .
        git commit -m $msg
        git push `get_current_repo` `get_current_branch`
    fi
    return $ret
}

cmd_checkout(){
    local target=`kvget target`
    local name=`kvget name`
    local ret=0

    if [ -n "$target" -a -n "$name" ]; then
        echo "checking out $target $name"
        git checkout -b $name
        git push -u $target $name
        cmd_stats
    else
        ret=23
    fi
    return $ret
}

list_branches(){
    #setup
    local ret=0
    local sep=":"
    local branches=`cmd_list`
    local br_arr=(`echo $branches`)
    local br_len=${#br_arr[@]}

    #create new list to enumerate branches for easier selection
    local N=$(seq 1 $br_len)
    local branch_list=(`echo $(_zip "$N" "$branches" $sep)`)
    local branch_len=${#branch_list[@]}

    export IFS=:
    local display_list=""
    #harvest branch list
    for ((i=0; i<$branch_len; i++)); do
        read -ra entry <<<"${branch_list[$i]}"
        #display entry with selection #
        display_list="$display_list
${YELLOW}${entry[0]}${NONE}) ${entry[1]}"
    done

    #echo -e first to preserve colors
    read -p "$(echo -e "$display_list
${GREEN}Please select a branch number:${NONE}")" br_num
    #check user input
    if [[ "$br_num" -gt 0 && "$br_num" -lt "$branch_len+1" ]]; then
        #parse branch name
        select_entry=(${branch_list[$br_num-1]})
        select_branch="${select_entry[1]}"
        #checkout and try to update branch
        #TODO: change pull to an invoke cmd_update or cmd_pull
        [ -n $select_branch ] && \
        (git checkout $select_branch || ret=$?) && \
        (git pull `get_current_repo` $select_branch || ret=$?) \
        || ret=23 #bad branch name
    fi
    #reset IFS?
    unset IFS
    return $ret
}

cmd_install(){ 
    git init
    git remote add origin "`kvget target`"
    git config branch.master.remote origin
    git config branch.master.merge refs/heads/master
    touch .gitignore
    kvset comment "Initial commit."
    cmd_checkin
}

cmd_clone(){
    # _repo=`kvget repo`
    # _repo_url=`kvget repo_url`
    # _dest=`kvget dest`
    # echo "cloning $_repo_url"
    url=`kvget target`
    out=`kvget output`

    if [ -n $out ]; then
        git clone $url $out
    else
        git clone $url
    fi
    # git clone --origin $_repo $_repo_url $_dest

    # cd $dest
    # npm install
    # bower install
    # gulp test

    # [[ $_dest = 5 ]] && a="$c" || a="$d"
    # --branch
    # for repo_name in `kvget repos`
    #    git remote add
}

cmd_request(){
    # local_branch="`get_current_repo`/`get_current_branch`"
    url="https://git.autodesk.com/portal-core/ui/compare/`get_current_branch`...`kvget target`"
    echo $url
    open -a "/Applications/Google Chrome.app" "$url"
    return 0
}

cmd_diff(){
    # difference between two branches
    git diff --stat --color master..branch    
}

cmd_ui(){
    br=`get_current_branch`
    bash --init-file <(echo '../../Desktop/g/src/commands/ui.sh')
    # open -a Terminal -W "../../Desktop/g/src/commands/ui.sh"
    # if [ -n "$br" ]; then
    #     ps1="\h \w \${br} $ "
    #     # export PS1="\[\033]0;\h \w \${br} \007\][\[\033[01;35m\]\h \[\033[01;34m\]\w \[\033[31m\]\${br}\[\033[00m\]]$ "
    # else
    #     ps1="$PWD> $ "
    # fi
    # export PS1=$ps1
    # echo $PS1
    # clear
}

cmd_debug(){
echo "
  debug command
-----------------"
dbg_opt=$(maybe `kvget _debug`)
echo "using option $dbg_opt"
}
