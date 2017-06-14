# oops :: text -> textSub -> IO()
oops(){
    local msg='Error trying to throw error.'
    local key=1
    local msgkey=''

    [[ $1 =~ '^[0-9]+$' ]] && key=$1
    [[ "$key" -gt 1 ]] && msgkey=`const KEY "$key"` \
    || msgkey="$1"

    [ -n "$msgkey" ] && msg=`const ERR "$msgkey" "$2"` \
    || msg=`const ERR "$2" "$3")`

    alert $key "$(const ERR $2 $3)" ERROR
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
    local div="─────────────────────────────────────────────"
    hcenter $div 47 $color1
    hcenter $icon "" $color1
    hcenter "$msg" "" $color2
    hcenter "Please see help (g h)."
    hcenter $div 47 $color1
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
    [ -n "$3" ] && color="$3" || color="${NONE}"

    newline=$'\n'
    IFS=$'\n'$'\r'
    for line in "$1"; do
        #use given line length
        #(for utf8 char that wc doesn't count well)
        local line_len
        [ -n "$2" ] && line_len="$2" || \
        line_len="`echo $line | wc -c | grep -E -o '\d+'`"

        if [[ $line_len -gt 0 ]]; then
            #calculate positioning
            local half_len=`expr $line_len / 2`
            local center=`expr \( $width / 2 \) - $half_len`
            #get left padding in spaces
            local spaces=""
            for ((i=0; i<$(abs $center); i++)) {
              spaces="$spaces "
            }
            #output
            echo -ne $color
            echo -n "$spaces$line$newline"
            echo -ne "${NONE}"
        fi
    done
}
