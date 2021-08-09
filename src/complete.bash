__cpu_fan_complete(){
	[[ $COMP_CWORD -gt 1 ]] && return

	if [[ $COMP_CWORD -eq 1 ]]; then
		COMPREPLY=($(compgen -W "status setup enable disable" $2))
		return
	fi
}

complete -F __cpu_fan_complete cpu-fan
