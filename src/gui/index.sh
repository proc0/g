# oops :: text -> textSub -> IO()
oops(){
    local msg='Error trying to throw error.'
    local key=1
    local msgkey=''

    ([[ "$1" =~ '^[0-9]+$' ]] && key=$1 && msgkey=`const KEY "$1"`) || \
    [ -n "$1" ] && msgkey=$1

    [ -n "$msgkey" ] && msg=`const ERR "$msgkey" "$2"`

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
    hcenter "$div" 47 "$color1"
    hcenter "$icon" "" "$color1"
    hcenter "$msg" "" $color2
    hcenter "Please see help (g h)."
    hcenter "$div" 47 "$color1"
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
    # echo "hi : $1"
    newline=$'\n'
    IFS=$'\n'$'\r'
    for line in "$1"; do
        local line_len=0
        #use given line length
        #(for utf8 char that wc doesn't count well)
        [ -n "$2" ] && line_len=$2 || \
        line_len=`echo $line | wc -c`

        if [[ "$line_len" -gt 0 ]]; then
            #calculate positioning
            local half_len=`expr $line_len / 2`
            local center=`expr \( $width / 2 \) - $half_len`
            #get left padding in spaces
            local spaces=""
            for ((i=0; i<$(abs "$center"); i++)) {
              spaces="$spaces "
            }
            #output
            echo -ne "$color"
            echo -n "$spaces$line$newline"
            echo -ne "${NONE}"
        fi
    done
}
