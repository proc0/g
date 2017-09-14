cmd_jump(){
    local stat_code=`get_status_code`

    if [ -n "$stat_code" ]; then
        echo -ne "Error: branch not in sync.\nCommit, branch, or discard changes.\n"
    else
        local _source=`kvget "source"`
        
        if [ -n "$_source" ]; then
            kvset "prev_source" "`get_current_repo`/`get_current_branch`"

            if [[ $_source =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
                local branch=${_source#*\/} repo=${_source%\/*}

                git checkout "$branch" &&
                cmd_update
            else
                echo -ne "`const TXT FETCHING_BRANCH`" &&
                list_branches "$_source"
            fi           
        else
            echo -ne "`const TXT FETCHING_BRANCH`" &&
            list_branches "`get_current_repo`"
        fi
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
