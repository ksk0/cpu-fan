#compdef cpu-fan

local -a reply
local -a args=(/$'[^\0]#\0'/)

local -a cpu_commands
#
_regex_words cpu-fan-commands "cpu-fan commands" \
	'enable:enable fan control at boot' \
	'disable:disable fan control at boot' \
	'status:show configuration, fan and temperature status' \
	'setup:setup temperature/fan_speed profile'

	args+=($reply[@])

_regex_arguments _cpu-fan "${args[@]}"

_cpu-fan "$@"
