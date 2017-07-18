# fst :: String -> String
fst(){
    echo `get_nth "$1" 1`
}
# snd :: String -> String
snd(){
    echo `get_nth "$1" 2`
}

# get_nth :: String -> Index -> Delim -> String
get_nth(){
    #note: 2nd field may contain delim (in url)
    #example url=$(echo `cut -d ':' -f 2,3,4 <<< $pair`)

    local delim=$3
    [ -z $delim ] && delim=':'

    cut -d "$delim" -f "$2" <<<"$1"
}

# _map :: Eval (String -> b) -> [String] -> [b]
# note: takes in space delimitted "[String]" pseudo
_map(){
    [ -z "$1" ] || 
    [ -z "$2" ] &&
    return 1

    local f=$1 a=(`echo "$2"`)
    local len_a=${#a[@]} idx=0 rv=""

    while [ $idx -lt $len_a ]; do
        local ret=`$f "${a[$idx]}"`
        rv="$rv $ret"
        idx=$((idx+1))
    done;
    echo $rv
}

# _filter :: Eval (String -> Bool) -> [String] -> [String]
# note: takes in space delimitted "[String]" pseudo
_filter(){
    [ -z "$1" ] || 
    [ -z "$2" ] &&
    return 1

    local f=$1 a=(`echo "$2"`)
    local len_a=${#a[@]} idx=0 rv=""

    while [ $idx -lt $len_a ]; do
        local item=${a[$idx]}
        local ret=`$f "$item" && echo "$?"`

        [[ $ret -eq 0 ]] && rv="$rv $item"
        idx=$((idx+1))
    done;
    echo $rv
}

_lt5(){
    local a=$1

    [ $a -lt 5 ] && return 0 || return 1
}
# zip :: String -> String -> String
_zip(){
    [ -z "$1" ] || 
    [ -z "$2" ] &&
    return 1

    local a1=(`echo "$1"`) b1=(`echo "$2"`) delim=":" rv="" idx=0
    local len_a=${#a1[@]} len_b=${#b1[@]}
    local len=$([[ $len_a -gt $len_b ]] && echo $len_a || echo $len_b)
    [ -n "$3" ] && delim="$3"
    
    while [ $idx -lt $len ]; do
        a2="${a1[$idx]}"
        b2="${b1[$idx]}"
        rv="$rv $a2$delim$b2"
        idx=$((idx+1))
    done;
    echo $rv
}

# spread :: String -> String
_spread(){
    local str="$*" newstr=""
    if [ -n "$str" ]; then
        for s in $(seq 1 ${#str}); do
            if [ $s -eq 1 ]; then
                newstr="${str:s-1:1}"
            else
                newstr="$newstr ${str:s-1:1}"
            fi
        done
    fi
    echo "$newstr"
}

# consants getter
# const :: Prefix -> Label -> String
const() { 
    local prefix=$1 label=$2
    local i="${prefix}_$label"
    echo "${!i}"
}

vartype() {
    local var=$( declare -p $1 )
    local reg='^declare -n [^=]+=\"([^\"]+)\"$'
    while [[ $var =~ $reg ]]; do
            var=$( declare -p ${BASH_REMATCH[1]} )
    done

    case "${var#declare -}" in
    a*)
        echo "ARRAY"
        ;;
    A*)
        echo "HASH"
        ;;
    i*)
        echo "INT"
        ;;
    x*)
        echo "EXPORT"
        ;;
    *)
        echo "OTHER"
        ;;
    esac
}
