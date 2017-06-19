cmd_stats(){
    local ret=0
    local status_text=`get_status`
    local status_code=`get_status_code`
    local target="`get_current_repo`/`get_current_branch`"
    local modded=''

    echo -e "${GREEN}$target | $status_text
─────────────────────────────────────────────${NONE}"
    if [[ "$status_code" == 'MODIFIED' ]]; then
        modded=`git ls-files -m`
        echo -e "${L_RED}$modded${NONE}"
    fi

}

#cmd_list :: () -> IO Int()
cmd_list(){
    local ret=0
    #list git branches and convert to list
    local target=$(kvget target || get_current_repo)
    local get_branches=$(fn repo 'git ls-remote --heads $repo;')
    local branches=$(list $(echo "`$get_branches $target`"))
    #discard branch ids, and format path to just branch name
    local get_paths=$(fn a '[[ $a == *\/* ]]')
    local format_path=$(fn a 'echo "${a##*/}"')
    #lets put it all together
    filter $get_paths "$branches" | map $format_path || ret=$?
    return $ret
}
#cmd_branch :: () -> IO Int()
cmd_branch(){
    local ret=0

    local input_branch=`kvget target`
    if [ -n "$input_branch" ]; then
        (git checkout "$input_branch" || ret=$?) &&
        (git pull "`get_current_repo`" "$input_branch" || ret=$?)
    else
        echo -ne "`const TXT FETCHING_BRANCH`" &&
        list_branches || ret=$?
    fi

    return $ret
}

cmd_merge(){
    local ret=0
    #TODO: check if conflicts, offer user to revert
    # cmd_revert="git revert -m 1 [sha_of_C9]"
    local cur_repo=`get_current_repo`
    local cur_branch=`get_current_branch`
    local target="$cur_repo/$cur_branch"
    [ -n "$target" ] && git merge "$target" || ret=$?
    cmd_stats
    return $ret
}

cmd_update(){
    local ret=0
    echo -e "`const TXT FETCHING_DATA`"
    # local repo_list=$(list `kvget remotes`)
    # map $(fn a 'echo \"updating $a...\" && git fetch $a') "$repo_list"    
    local repo_len=${#remotes[@]}
    while [[ repo_len -gt 1 ]]; do
        local idx=$((repo_len-1))
        repo="${remotes[$idx]% : *}"
        # url="${remotes[$idx]#* : }"
        echo -e "updating $repo ..."
        git fetch $repo || ret=$?
        repo_len=$idx
    done
    local _ret=$?
    [[ "$_ret" -gt 0 ]] && ret=$_ret
    cmd_stats
    return $ret
}

cmd_checkin(){
    local ret=0

    local msg=`kvget comment`
    local status_code=`get_status_code`
    #no comment value
    [ -z "$msg" ] && ret=14

    if [[ "$status_code" == 'SYNCED' ]]; then
        echo "`const TXT UP_TO_DATE`"
    elif [[ "$status_code" == 'UNTRACKED' ]]; then
        return 99
    elif [[ "$status_code" == 'AHEAD' ]]; then
        git push "`get_current_repo`" "`get_current_branch`"
        cmd_stats        
    elif [ -n "$msg" ]; then
        git add -A .
        git commit -m "$msg" || ret=$?
        git push "`get_current_repo`" "`get_current_branch`"
        cmd_stats
    fi
     _ret=$? #update ret if needed
    [ $_ret -gt 0 ] && ret=$_ret
    return $ret
}

cmd_checkout(){
    local target=`kvget target`
    local name=`kvget name`
    local ret=0

    if [ -n "$name" ]; then
        if [[ $name =~ \/{1} ]]; then
            local repo="${name%\/*}"
            local branch="${name#*\/}"
            # echo "br: $branch, rp: $repo"
            git checkout -b "$branch"
            git push -u "$repo" "$branch"
        else
            # echo "no name br: $name, rp: $target"
            git checkout -b "$name"
            git push -u "$target" "$name"
        fi
    else
        name="`get_current_branch`_$(date +%s)"
        git checkout -b "$name"
        git push -u "$target" "$name"
    fi
    cmd_stats
    return $ret
}

list_branches(){
    local ret=0
    #setup
    local branches=`cmd_list`
    local br_arr=(`echo $branches`)
    local br_len=${#br_arr[@]}
    #create new list to enumerate 
    #branches for easier selection
    local sep=":"
    local N=$(seq 1 $br_len)
    local br_list=$(_zip "$N" "$branches" "$sep")
    local branch_list=(`echo $br_list`)

    export IFS=:
    local display_list=""
    local branch_len=${#branch_list[@]}
    #compute branch list
    for ((i=0; i<$branch_len; i++)); do
        read -ra entry <<<"${branch_list[$i]}"
        local num="${YELLOW}${entry[0]}${NONE}"
        local branch_name="${entry[1]}"
        #building list...
        display_list="$display_list\n$num) $branch_name"
    done

    #get user input
    query_user="${GREEN}`const TXT SELECT_BRANCH`${NONE}"
    #echo -e first to preserve colors
    read -p "$(echo -e "$display_list\n$query_user")" br_num

    #check user input
    if [[ "$br_num" -gt 0 && "$br_num" -lt "$branch_len+1" ]]; then
        #parse branch name
        select_entry=(${branch_list[$br_num-1]})
        select_branch=${select_entry[1]}
        #checkout and try to update branch
        #TODO: change pull to an invoke cmd_update or cmd_pull
        [ -n "$select_branch" ] && \
        (git checkout "$select_branch" || ret=$?) && \
        (git pull "`get_current_repo`" "$select_branch" || ret=$?) \
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
    # for repo_name in `kvget remotes`
    #    git remote add
}

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

cmd_diff(){
    # difference between two branches
    git diff --stat --color master..branch    
}

cmd_config(){
    local ret=0
    local target=`kvget target`
    local target_name=`kvget name`
    local is_default=0

    [ -z "$target_name" ] && is_default=1

    if [ $is_default -eq 1 ]; then
        echo "setting target $target as default"
    else 
        echo "setting target $target_name to $target"
    fi
    return $ret
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
dbg_opt=`kvget _debug`
echo "using option $dbg_opt"
}
