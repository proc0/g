cmd_back(){
	set -x
	local prev_branch=`kvget prev_source`
	[ -n "$prev_branch" ] && kvset 'source' "$prev_branch"
	cmd_jump
	return $?
}