
defn nothing a 'return 0'

defn identity a 'echo $a'
defn maybe a 'if [ -n "$a" ]; then $identity "$a"; else $nothing; fi'

defn _id a '
    echo $(map $identity $(list $a))'

defn _concat a b '
    echo "$_id $(list $($_id $(list $a)) $($_id $(list $b)))"'

defn _zip a b c '
    a1=(`echo $a`)
    b1=(`echo $b`)
    len_a="${#a1[@]}"
    len_b="${#b1[@]}"
    len=$([[ $len_a -gt $len_b ]] && echo $len_a || echo $len_b)
    __=$([ -n "$c" ] && echo $c || echo :)

    rv=""
    idx=0 
    while [ $idx -lt $len ]; do
        _a1="${a1[$idx]}";
        _b1="${b1[$idx]}";
        rv="$rv $_a1$__$_b1"
        idx=$((idx+1));
    done;
    echo $rv;'
    
