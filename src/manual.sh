#change IFS
#to allow /n
_ifs=$IFS
export IFS=:

usage="
### NAME
| ${0##*/} | -- git command line workflow toolkit |
| -------- | ------------------------------------ |
### SYNOPSIS
| ${0##*/} | COMMAND | (-)OPTION(*) ... [VALUE] | 
|----------|---------|----------------------|
|          | h, v    |
|          | s, ui   |          
|          | ls, br, mr, up | -t [TARGET] |
|          | ci, co  | -m* [MESSAGE] -n [NAME] -t [TARGET] |
|          | in, cl  | -t* [TARGET] | -o [OUTPUT] |   
|          | pr, df  | -t* [TARGET] |

### DESCRIPTION
    A set of git worfklows wrapped in shortcut commands.
    
### COMMANDS
    NAME        ALIAS       (-)OPTION(*)=DEFAULT        DESCRIPTION 
    ------------------------------------------------------------------------

    version     -v|v                                    Show version.

    stats       st|s                                    Show current state 
                                                        and git status.

    list        ls|-l       -t<target>=CURRENT_REPO     List branches
                                                        from target repo.
                                                        Defaults to current
                                                        repo.
                                                        
    branch      br|-b       -t<target>=INTERACTIVE      Switch to a branch.
                                                        Target is optional,
                                                        and can be either 
                                                        a branch or a 
                                                        repo/branch.

    merge       mr|-m       -t<target>=REMOTE_TARGET    Merge local to a 
                                                        _remote_ target.
                                                        Defaults to the
                                                        _tracked_ branch's
                                                        remote repo/branch.

    update      up|-u       -t<target>=REMOTE_REPOS     Fetch latest from
                                                        all configured 
                                                        remotes by default,
                                                        or specify a repo.

    checkin     ci|-c*      -c<comment>*                Stage, commit 
                            -t<target>=REMOTE_TARGET    and push changes,
                                                        to current repo.
                                                        Git comment text
                                                        is required.

    checkout    co|-k       -k|-n<name>=BASE_TIMESTAMP  Branch off from
                            -t<target>=REMOTE_TARGET    current branch.
                                                        Optional target if
                                                        not branching from
                                                        selected branch.
                                                        Name defaults to 
                                                        generated parent
                                                        name + timestamp.  

    install     in          -t<target>*                 Create a git repo
                            -o<output>=CURRENT_DIR      from current dir.,
                                                        and push to a remote
                                                        target. Optional 
                                                        output for a diff.
                                                        directory.
                    
    clone       cl          -t<target>*                 Clone target
                            -o<output>=CURRENT_DIR      and setup local 
                                                        configurations. 

    request     pr          -t<target>*                 Build a pull
                                                        request url and
                                                        open in browser.

    diff        df          -t<target>*                 Run a git diff 
                                                        
    ui          ui                                      WIP


### OPTIONS
    NAME        ALIAS       (-)OPTION(*)=DEFAULT        DESCRIPTION 
    ------------------------------------------------------------------------

    --target     -t         [ REPO NAME | BRANCH NAME | REPO/BRANCH ]
                            When not required, this options 
                            defaults to the current selected repo 
                            and branch in the current git directory. 
                            The target type (branch, repo or both) 
                            depend on the command.

    --name       -n         [ BRANCH NAME ] 
                            The branch name when creating a new branch. 
                            When no name is given, the branch name 
                            defaults to the name of the base branch, 
                            plus a timestamp.

    --message    -m         [ GIT MESSAGE ]
                            The message to be sent with the git 
                            commit command; cannot be empty.

    --output     -o         [ PATH ]
                            The path to the directory where the init 
                            command will clone and run scripts to 
                            initialize the codebase.
"
export IFS=$_ifs
