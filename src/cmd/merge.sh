cmd_merge(){
    local ret=0
    #TODO: check if conflicts, offer user to revert
    # cmd_revert="git revert -m 1 [sha_of_C9]"
    local cur_repo=`get_current_repo`
    local cur_branch=`get_current_branch`
    local target="$cur_repo/$cur_branch"

    cmd_update
    [ -n "$target" ] && git merge "$target" || ret=$?
    [ $ret -gt 0 ] && return $ret
    cmd_status
    return $?
}
