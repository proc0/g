cmd_branch(){
    local ret=0
    local stat_code=`get_status_code`
    if [[ "$stat_code" == 'MODIFIED' ]];then
        echo 'Commit or stash changes first.'
    else
        local target=`kvget target`
        if [ -n "$target" ]; then
            if [[ $target =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
                local branch=${target#*\/}
                local repo=${target%\/*}
                (git checkout "$branch" || ret=$?) &&
                (git pull "$repo" "$branch" || ret=$?)
            else
                local t_branch=$target
                local t_repo=`get_current_repo`
                (git checkout "$t_branch" || ret=$?) &&
                (git pull "$t_repo" "$t_branch" || ret=$?)
            fi           
        else
            echo -ne "`const TXT FETCHING_BRANCH`" &&
            list_branches || ret=$?
        fi
    fi
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