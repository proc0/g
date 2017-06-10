#change IFS
#to allow /n
_ifs=$IFS
export IFS=:

usage="
NAME
   ${0##*/} -- git command line workflow toolkit

SYNOPSIS
    ${0##*/} [ COMMAND ]        [ -OPTION ... ] 
      [ h, v ]
      [ s, ui ]          
      [ ls, br, mr, up ] [ -t TARGET ]
      [ ci, co ]         [ -t TARGET ]  [ -m MESSAGE* | -n NAME ]
      [ in, cl ]         [ -t TARGET* ] [ -o OUTPUT ]   
      [ pr, df ]         [ -t TARGET* ]

DESCRIPTION
    A set of git recipies wrapped in short shell commands.
    
COMMANDS -------------------------------------------------------------+
  |             DESCRIPTION          ALIAS       --OPTION [REQ*, =DEFAULTS]
  +-------------------------------------------------------------------+
    help        Show this help        -h|h                  
                message.

    version     Show version.         -v|v

    stats       Show current state    st|s 
                configuration and
                local git status

    list        List branches         ls|-l      --target=CURRENT_REPO
                from target repo.
                Defaults to current
                repo.                 
    
    branch      Switch to a branch.   br|-b      --target=INTERACTIVE
                Target is optional,
                and can be either
                a branch or a 
                repo/branch.

    merge       Merge local to a      mr|-m      --target=REMOTE_TARGET
                _remote_ target.
                Defaults to the 
                _tracked_ branch's
                remote repo/branch.       

    update      Fetch latest from     up|-u      --target=REMOTE_REPOS
                all configured 
                remotes by default,
                or specify a repo.

    checkin     Stage, commit         ci|-c*     --target=REMOTE_TARGET
                and push changes,                --comment*
                to current repo.
                Git comment text
                is required.

    checkout    Branch off from       co|-k      --target=CURRENT_BRANCH
                current branch.                  --name=BASE_TIMESTAMP
                Optional target if
                not branching from
                selected branch. 
                Name defaults to 
                generated parent
                name + timestamp.                

    install     Create a git repo      in        --target*
                from current dir.,               --output=CURRENT_DIR
                and push to a remote
                target. Optional 
                output for a diff.
                directory.

    clone       Clone target           cl        --target*
                and setup local                  --output=./REPO_NAME
                configurations.                   

    request     Build a pull           pr        --target*
                request url and 
                open in browser.

    diff        Run a git diff         df        --target*        

    ui          Modify console         ui        
                to always show 
                status info 

OPTIONS -------------------------------------------------------------+
  |             ALIAS       ARGUMENTS                                +
  +------------------------------------------------------------------+
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

EXAMPLES -----------------------------------------------------------+
  |                             COMMAND          ARGUMENTS          +
  +-----------------------------------------------------------------+    
    Display current context     ${0##*/} s      
    state (including git 
    stats and config vars)

    Displays version            ${0##*/} v

    Initialize git repo and
    remote configuration,       ${0##*/} i        -r REPO_NAMES
    and run init scripts                          -o OUTPUT_DIR
"
export IFS=$_ifs
