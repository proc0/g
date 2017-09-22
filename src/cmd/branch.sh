cmd_branch(){
    local stat_code=`get_status_code` transfer

    if [ -n "$stat_code" ]; then
        echo -ne "Warning: branch has uncommitted changes.\nTransfer the changes to another branch? y/N\n"
        read transfer
    else
        transfer="y"
    fi

    if [ -n "$transfer" ];then
        local target=`kvget target`
        local cur_repo=`get_current_repo`
        kvset "prev_target" "$cur_repo/`get_current_branch`"

        if [ -n "$target" ]; then
            if [[ $target =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then
                local repo="${target%\/*}"
                local branch="${target#*\/}"

                if [ -n "$transfer" ]; then
                    git checkout "$branch"
                else
                    git checkout -b "$branch"
                    git push -u "$repo" "$branch"
                fi
            else
                local repo=$cur_repo                
                git checkout -b "$target"
                git push -u "$repo" "$target"
            fi
        else
            echo -ne "`const TXT FETCHING_BRANCH`" &&
            list_branches "$cur_repo"            
        fi

        cmd_status
    fi

    return $ret
}
