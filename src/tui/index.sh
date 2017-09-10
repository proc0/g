# oops :: ErrCodeOrErrKey  -> $@ -> IO()
oops(){
    set +x
    local err_code=1
    local err_key=''
    local err_msg="Error trying to throw an error. :'("
    #if the code is a number and greater than 9
    #set error_code or oops was called with error key
    #note: do not expand variable for regexp checks
    [[ $1 =~ ^[0-9]+$ && $1 -gt 9 ]] && err_code=$1 \
    || [[ $1 =~ ^[A-Z_]+$ ]] && err_key=$1
    #if error code was used, get the error key with it
    [ $err_code -gt 1 ] && err_key=`const KEY $1`
    #get the actual error message
    [ -n "$err_key" ] && err_msg=`const ERR $err_key`

    alert $err_code "$err_msg" ERROR
    exit $err_code
}
panel_cache=""
# alert :: ErrorCode -> ErrorMessage -> ErrorType -> IO()
alert(){
    # ☠ ☹ ☣ ⌛✘ ✔
    local msg=$(fold -w 54 -s <<<"$2")
    local props=(`const ALR "$3"`)
    local color1="${props[1]}"
    local icon="${props[0]}  \$?:$1"
    local color2="${props[2]}"
    local div='─────────────────────────────────────────────'
    echo -ne "${ALERT}"
    panel_row "$div" "47" $color1
    panel_row "$icon" "" $color1
    panel_row "$msg" "" $color2
    panel_row "`const TXT SEE_HELP`"
    panel_row "$div" "47" $color1
    echo -ne "$panel_cache"
}
# abs :: Int -> Nat
function abs {
   [ $1 -lt 0 ] && echo $((-$1)) || echo $1
}
# panel_row - center text horizontally
# panel_row :: text -> optionTextWidth -> optionColor -> IO()
function panel_row {
    local color="${NONE}" \
        width=`tput cols` \
        newline=$'\n'
    # optional color
    [ -n "$3" ] && color=$3

    IFS=$'\n'$'\r'
    for line in "$1"; do
        local line_len=0
        # use given line length
        # (for utf8 char that wc doesn't count well)
        [ -n "$2" ] && line_len=$2 || \
        line_len=`echo $line | wc -c`

        if [ $line_len -gt 0 ]; then
            #calculate positioning
            local half_len=`awk -v "llen=$line_len" 'BEGIN { rounded = sprintf("%.0f", llen/2); print rounded }'`
            local center=0
            [[ $half_len -gt 0 ]] && \
            center=`expr \( $width / 2 \) - $half_len`
            # get left padding in spaces
            if [ $center -gt 0 ]; then
                local spaces=""
                for ((i=0; i<$(abs $center); i++)) {
                  spaces="$spaces "
                }
                panel_cache="$panel_cache$color$spaces$line$newline${NONE}"
            fi
        fi
    done
    unset IFS
}
