cmd_merge(){
    local target=`kvget target`
    if [[ $target =~ [a-zA-Z0-9]\/[a-zA-Z0-9] ]]; then 
        #TODO: check if conflicts, offer user to revert
        # cmd_revert="git revert -m 1 [sha_of_C9]"
        git merge "$target"
        cmd_status
    fi
    return $?
}
