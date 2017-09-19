cmd_back(){
	local prev_branch=`kvget prev_target`
	[ -n "$prev_branch" ] && kvset 'target' "$prev_branch"
	cmd_jump
	return $?
}
