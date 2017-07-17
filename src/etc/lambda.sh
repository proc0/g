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
# zip :: String -> String -> String
_zip(){
    [ -z "$1" ] || [ -z "$2" ] &&
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

# zip :: String -> String -> String
# defn _zip a b c '
#     a1=(`echo "$a"`)
#     b1=(`echo "$b"`)
#     len_a="${#a1[@]}"
#     len_b="${#b1[@]}"
#     len=$([[ $len_a -gt $len_b ]] && echo $len_a || echo $len_b)
#     __=$([ -n "$c" ] && echo $c || echo :)

#     rv=""
#     idx=0 
#     while [ $idx -lt $len ]; do
#         _a1="${a1[$idx]}";
#         _b1="${b1[$idx]}";
#         rv="$rv $_a1$__$_b1"
#         idx=$((idx+1));
#     done;
#     echo $rv;'

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

# defn _times str n '
#     idx=0
#     len=$n
#     list=""
#     if [ $len -gt 0 ]; then
#         while [ $idx -lt $len ]; do
#             list="$list$str"
#             idx=$((idx+1))
#         done
#     fi
#     echo $list'
