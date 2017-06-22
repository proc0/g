cmd_install(){ 
    git init
    git remote add origin "`kvget target`"
    git config branch.master.remote origin
    git config branch.master.merge refs/heads/master
    touch .gitignore
    kvset comment "Initial commit."
    cmd_checkin
}
