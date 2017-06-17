#change IFS
#to allow /n
_ifs=$IFS
export IFS=:
x=${0##*/}
usage="
### NAME
    $x -- git command line workflow toolkit 

### SYNOPSIS
    $x  [ COMMAND ] [ -OPTION <VALUE>... ]
    $x  [ h | v ]
       [ s | ui ]
       [ ls | br | mr | up ] [ -t <TARGET> ]
       [ ci | co ] [ -c* <COMMENT> | -n <NAME> | -t <TARGET> ] 
       [ in | cl ] [ -t* <TARGET> | -o <OUTPUT> ]
       [ pr | df ] [ -t* <TARGET> ] 

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

    comment     -c          < COMMENT >
                            The git commit message, required for both
                            ci -c, and -c commands.

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
