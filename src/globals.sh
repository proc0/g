kvset version "v0.01.00"

#COLORS
RED='\033[00;31m'
YELLOW='\033[01;33m'
GREEN='\033[00;32m'
BLUE='\033[00;34m'
CYAN='\033[00;36m'
PURPLE='\033[00;35m'
BROWN='\033[01;33m'
GRAY='\033[01;30m'
WHITE='\033[01;37m'
L_RED='\033[01;31m'
L_GREEN='\033[01;32m'
L_BLUE='\033[01;34m'
L_CYAN='\033[01;36m'
L_PURPLE='\033[01;35m'
L_GRAY='\033[00;37m'
NONE='\033[00m'
#STYLES
BOLD='\033[1m'
UNDERLINE='\033[4m'
#SOUND
ALERT='\a'

#MESSAGES
#-------------------------
#Status ------------------
declare "STS_SYNCED=✔ sync'ed"
declare "STS_MODIFIED=${RED}✘ modified"
declare "STS_BEHIND=${YELLOW}⏱  behind"
declare "STS_AHEAD=${YELLOW}⏱  ahead"
declare "STS_ERROR=${RED}☠ error"
#Alert text and style
#ALERT_TYPE=ICON COLOR1 COLOR2
declare "ALR_INFO=☏ ${WHITE}"
declare "ALR_WARNING=☣ ${YELLOW}"
declare "ALR_ERROR=☠ ${RED} ${L_RED}"

declare "TXT_SELECT_BRANCH=Please select a branch number:"
declare "TXT_FETCHING_BRANCH=⌛  fetching branch list..."
declare "TXT_FETCHING_DATA=⌛  fetching remote data..."
declare "TXT_UP_TO_DATE=Already up to date."

#Error messages -----------
#NO SOMETHING
declare "KEY_10=NO_GIT"
declare "KEY_11=NO_CONFIG"
declare "KEY_12=NO_CONNECTION"
declare "KEY_13=NO_COMMAND"
declare "KEY_14=NO_ARGVAL"
declare "ERR_NO_GIT=Not a git directory: $(pwd)"
declare "ERR_NO_COMMAND=At least one command is required."
declare "ERR_NO_ARGVAL=Option value required but not found."
declare "ERR_NO_CONNECTION=Unable to connect with remote."
declare "ERR_NO_CONFIG=Bad config file: $config"
#BAD FORM
declare "KEY_20=BAD_GIT"
declare "KEY_21=BAD_CONFIG"
declare "KEY_22=BAD_COMMAND"
declare "KEY_23=BAD_ARGVAL"
declare "ERR_BAD_GIT=Something wrong with git."
declare "ERR_BAD_COMMAND=Command not found: $1"
declare "ERR_BAD_ARGVAL=Unexpected option value $2"
#OTHER
declare "KEY_99=GENERIC"
declare "ERR_GENERIC=:("


# consants getter
# const :: () -> String
const() { 
    local array=$1 index=$2
    local i="${array}_$index"
    echo "${!i}"
}
