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