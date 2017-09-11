cmd_back(){
	local prev_branch=`kvget prev_source` ret=0

	[ -n "$prev_branch" ] && echo $prev_branch
	
	return $ret
}