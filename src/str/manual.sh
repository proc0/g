#change IFS
#to allow /n
_ifs=$IFS
export IFS=:
x=${0##*/}
#:<<proc0
#        _,.---'---.,_
#     ,-*             *-.
#   ,^                   ^.
#  /          ⛧           |.
# (:.                     .\' 
# |::)^-  .~.,   .~ .  -^(@ )
# \:( .--..   ) (   .--.. ): 
#  (:(   _ '-. V ,-' _   ) /
#  ):! .(Q). / A \ .(Q). !  
# .-:(::,.--" /^\ "--.,::) -.
# (::-~  _.  (_|_)   ._  -  )
#  *-.:,T. : . '       T._,*
#       ):): ) : ( ( .(
#       [.::::.:.: : ,]
#        '*($(_|_),)-'
# proc0
usage="
### NAME
    $x -- git command line workflow toolkit 


### SYNOPSIS
    $x  [ INFO COMMAND ]
       [ h | v | s ]
        
    $x  [ SHORTCUT COMMAND ] <VALUE>
       [ -l | -b | -m | -u ] <TARGET | BRANCH | REPO/BRANCH>
       [ -c | -k ] <COMMENT | NAME>

    $x  [ EXPANDED COMMAND ] [ -option1 <VALUE1> -option2 <VALUE2>... ]
       [ ls | br | mr | up ] [ -t <TARGET> ]
       [ ci | co ] [ -c* <COMMENT> | -n <NAME> | -t <TARGET> ] 
       [ in | cl ] [ -t* <TARGET> | -o <OUTPUT> ]
       [ pr | df ] [ -t* <TARGET> ] 


### DESCRIPTION
    A set of git worfklows wrapped in shortcut commands.


### COMMANDS
    NAME        ALIAS       -o(option)*[required]       DESCRIPTION 
                            <OPTION TYPE>--DEFAULT          
    ------------------------------------------------------------------------
    help        h|-h                                    Show this.

    
    version     v|-v                                    Show version.


    stats       s                                       Show current branch
                                                        and local status.


    list        ls|-l       -t(target)                  List branches
                            <REPO>--CURRENT_REPO        from a target repo.
                                                        Defaults to current.


    branch      br|-b       -t(target)                  Switch to a branch.
                            <BRANCH                     Target is optional,
                            | REPO/BRANCH>              and can be either 
                            --INTERACTIVE               a branch or a 
                                                        repo/branch.


    merge       mr|-m       -t(target)                  Merge local to a 
                            <TARGET                     remote branch.
                             | BRANCH                   Defaults to the
                             | REPO/BRANCH>             current branch's 
                            --REMOTE_BRANCH             tracked remote.


    update      up|-u       -t(target)                  Update remotes list-
                            <TARGET | REPO>             ed in config file,
                            --REMOTE_REPO(S)            or specify a remote.


    checkin     ci|-c*      -t(target)                  Add all changed
                            <TARGET                     files, commit with
                             | BRANCH                   comment message,
                             | REPO/BRANCH>             and push changes
                            --REMOTE_BRANCH             to current tracked
                                                        remote branch by 
                            -c(comment)*<STRING>        default.
                                                        

    checkout    co|-k       -t(target)                  Branch off from
                            <TARGET                     current branch.
                             | BRANCH                   Optional target if
                             | REPO/BRANCH>             not branching from
                            --REMOTE_BRANCH              selected branch.
                                                        Name defaults to 
                            -k|-n(name)                 generated parent
                            <STRING>                    name + timestamp.  
                            --BASE_TIMESTAMP


    install     in          -t(target)*                 Create a git repo
                            <REPO | REPO_URL>           in the current dir.,
                                                        and push to a remote
                            -o(output)                  target. Optional 
                            <PATH>                      output to a diff-
                            --CURRENT_DIR               erent directory.


    clone       cl          -t(target)*                 Clone a git repo
                            <REPO                       and setup local 
                             | REPO_URL>                configurations. 
                                                        Creates a dir. with
                            -o(output)                  the repo name by 
                            <PATH>--CURRENT_DIR         default.


    request     pr          -t(target)*                 Build a pull request
                            <TARGET                     with the target as 
                             | BRANCH                   the base. Provide a
                             | REPO/BRANCH>             comment option that 
                            --REMOTE_BRANCH             requires both title
                                                        and body of the pull
                            -c(comment)*                request. 
                            <STRING:FORMAT=             Use {body} to separate
                            \"TITLE{body}BODY\">        title from body...            
                                                        i.e. \"Some Title \\
                                                        {body}Body text here\".

--- WIP ---

    config      cf          -t<target>=DEFAULT_TARGET   Configure the remote
                            -n<name>=SET_AS_DEFAULT     targets and/or set
                                                        the default target by
                                                        using a literal 
                                                        remote/branch name, or
                                                        target label. (WIP)


    diff        df          -t(target)*                 Run a git diff (WIP)


    ui          ui                                      (WIP)


### OPTIONS
    OPTION      FLAG        POSSIBLE VALUES AND DESCRIPTION 
    ------------------------------------------------------------------------

    target      -t          < REMOTE NAME | BRANCH NAME | REMOTE/BRANCH >
                            When not required, this options 
                            defaults to the CURRENT TARGET which can be
                            any of the above values. If not sure, you can be
                            explicit by always supplying a REMOTE/BRANCH.

    name        -n          < BRANCH NAME | WIP:REMOTE NAME >
                            Name of the branch or remote for checkout
                            and remote configuration(wip). Defaults to 
                            timestamp prefixed plus base branch name.

    comment     -c          < STRING >
                            The git commit message, required for both
                            ci -c, and -c commands, also used for pr command
                            where the string should contain both the title 
                            and body of the pr.

    output      -o          < DIR PATH >
                            The path to the directory where the init 
                            command will clone and run scripts to 
                            initialize the codebase. Defaults to current.


### EXAMPLES
    WORKFLOW                    COMMAND
    ------------------------------------------------------------------------ 
    Checkout a new branch       g -k new_branch
    and set its upstream 
    to the default target
    (set in config.yml).

    After changes are made      g -c \"made some changes\"
    to the new branch. 
    Checkin all the changes 
    to the default target.

    Checkout a new branch       g co -n new_branch1 -t remote2/new_branch1
    and specify a target
    upstream.

    Checkin the new branch      g ci -c \"made more changes\" -t remote2/new_branch1
    and make sure to spec-
    ify target (assuming 
    remote2 not default).

    Set that new remote         g cf -t remote2/newbranch1
    to the default target,
    for faster workflow.

    After more changes,         g -c \"yet more changes to branch1\"
    checkin the changes, 
    without the need to 
    specify a target.

    Create a remote label       g cf -t remote3/somebranch -n target3
    for multiple target
    checkins.

    Checkout a new branch       g co -n newbranch3 -t target3
    from the new target,        g ci -c \"transferring branch to remote3\" -t target3
    and merge changes to 
    the target, by using 
    its label.

    Same as above but first,    g cf -t target3
    set default target to       g -k newbranch3
    ommit -t option.            g -c \"transferring branch to remote3\"
"
export IFS=$_ifs