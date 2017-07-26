cmd_status(){
    # local ret=0
#     local status_text=`get_status`
#     local status_code=`get_status_code`
#     local target="`get_current_repo`/`get_current_branch`"
#     local modded=''

#     echo -e "${GREEN}$target | $status_text
# ─────────────────────────────────────────────${NONE}"
#     if [[ "$status_code" == 'MODIFIED' ]]; then
#         modded=`git ls-files -m`
#         echo -e "${L_RED}$modded${NONE}"
#     fi
#test
    git status --branch --untracked --long --porcelain
    
}
