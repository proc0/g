cmd_back(){
	local prev_branch=`kvget prev_source`
	[ -n "$prev_branch" ] && kvset 'source' "$prev_source"
	cmd_jump
	return $?
}