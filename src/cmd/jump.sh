cmd_jump(){
    local stat_code=`get_status_code`

    if [ -n "$stat_code" ]; then
        echo -ne "Error: branch not in sync.\nCommit, branch, or discard changes.\n"
    else
        local _source=`kvget "source"`
        
        if [ -n "$_source" ]; then
            if [[ $_source =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
                local branch=${_source#*\/} repo=${_source%\/*}
                git checkout "$branch"
            else
                local repo_exists="`find_repo "$_source"`"
                # if there's a repo match, list branches
                if [ $? -eq 0 ]; then
                    echo -ne "`const TXT FETCHING_BRANCH`" &&
                    list_branches "$_source"
                else
                    # source must be a branch
                    git checkout "$_source"
                fi
            fi           
            cmd_update
        else
            echo -ne "`const TXT FETCHING_BRANCH`" &&
            list_branches "`get_current_repo`"
        fi
        kvset "prev_source" "`get_current_repo`/`get_current_branch`"
    fi
    
    return $?
}

list_branches(){
    local ret=0 \
        # setup
        cur_repo=$1 \
        branches=`cmd_list_branches` \
        br_arr=(`echo $branches`) \
        br_len=${#br_arr[@]} \
        # create new list to enumerate 
        # branches for easier selection
        N=$(seq 1 $br_len) sep=":" \
        br_list=$(_zip "$N" "$branches" "$sep") \
        branch_list=(`echo $br_list`);

    # build display list
    export IFS=:
    local display_list="" \
        branch_len=${#branch_list[@]};
    # compute branch list
    for ((i=0; i<$branch_len; i++)); do
        read -ra entry <<<"${branch_list[$i]}"
        # enumerate branch names #) branch_name
        local num="${YELLOW}${entry[0]}${NONE}" \
            branch_name="${entry[1]}";
        # building list...
        display_list="$display_list\n$num) $branch_name"
    done

    # get user input
    local query_user="`const TXT SELECT_BRANCH`"
    # echo -e first to preserve colors
    read -p "$(echo -e "$display_list\n$query_user")" br_num
    # check user input
    if [[ "$br_num" -gt 0 && "$br_num" -lt "$branch_len+1" ]]; then
        # parse branch name
        local select_entry=(${branch_list[$br_num-1]}) \
            select_branch=${select_entry[1]};
        # checkout and try to update branch
        if [ -n "$select_branch" ]; then
            kvset "prev_source" "`get_current_repo`/`get_current_branch`"
            kvset "source" "$_source"
            git checkout "$select_branch"
            cmd_update
        else
            ret=23 # bad branchname
        fi
    fi
    # reset IFS?
    unset IFS
    return $ret
}

find_repo(){
    local ret=0
    local repo_len=${#cfg_remotes[@]}
    local found=1
    local match=''
    #update cfg_remotes if cfg_remotes exists
    while [ $repo_len -gt 0 -o $repo_len -eq 0 ]; do
        local idx=$((repo_len-1))
        if [ $idx -gt 0 -o $idx -eq 0 -o $found -eq 0 ]; then
            local pair=${cfg_remotes[$idx]}
            #split pair into 1st and 2nd field w/ cut
            #note: 2nd field may contain delim (in url)
            #local url=$(echo `cut -d ':' -f 2,3,4 <<< $pair`)
            local repo=$(echo `cut -d ':' -f 1 <<< $pair`)
            local remote_exists=`check_remote "$repo"`
            #check return code to
            #prevent it from propagating
            if [[ $remote_exists == 0 ]]; then
                found=0
                match="$repo"
            fi
        fi
        #countdown
        repo_len=$idx
    done

    echo "$match"
}
