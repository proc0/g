cmd_new(){
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

cmd_install(){ 
    git init
    git remote add origin "`kvget target`"
    git config branch.master.remote origin
    git config branch.master.merge refs/heads/master
    touch .gitignore
    kvset comment "Initial commit."
    cmd_checkin
}
