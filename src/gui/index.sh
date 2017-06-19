# oops :: text -> textSub -> IO()
oops(){
    local msg='Error trying to throw error.'
    local key=1
    local msgkey=''

    [[ $1 =~ ^[0-9]+$ && $1 -gt 9 ]] && key=$1 \
    || ([[ "$1" =~ ^[A-Z_]+$ ]] && msgkey=$1)

    [ $key -gt 1 ] && msgkey=`const KEY $1`


    [ -n "$msgkey" ] && msg=`const ERR $msgkey`

    alert "$key" "$msg" ERROR
    exit $key
}
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
    hcenter "$div" "47" $color1
    hcenter "$icon" "" $color1
    hcenter "$msg" "" $color2
    hcenter "`const TXT SEE_HELP`"
    hcenter "$div" "47" $color1
}
# abs :: Int -> Nat
function abs {
   [ $1 -lt 0 ] && echo $((-$1)) || echo $1
}
# hcenter - center text horizontally
# hcenter :: text -> optionTextWidth -> optionColor -> IO()
function hcenter {
    #console width
    local width=`tput cols`
    #optional color
    local color
    [ -n "$3" ] && color=$3 || color="${NONE}"
    # echo "hi : $1"
    newline=$'\n'
    IFS=$'\n'$'\r'
    for line in "$1"; do
        local line_len=0
        #use given line length
        #(for utf8 char that wc doesn't count well)
        [ -n "$2" ] && line_len=$2 || \
        line_len=`echo $line | wc -c`

        if [ $line_len -gt 0 ]; then
            #calculate positioning
            # local half_len=`expr $line_len / 2`
            local half_len=` awk -v "llen=$line_len" 'BEGIN { rounded = sprintf("%.0f", llen/2); print rounded }'`
            local center=0
            [[ $width -gt 0 && $half_len -gt 0 ]] && center=`expr \( $width / 2 \) - $half_len`

            #get left padding in spaces
            if [ $center -gt 0 ]; then
                local spaces=""
                for ((i=0; i<$(abs $center); i++)) {
                  spaces="$spaces "
                }
                #output
                echo -ne $color
                echo -n "$spaces$line$newline"
                echo -ne "${NONE}"
            fi
        fi
    done
}
