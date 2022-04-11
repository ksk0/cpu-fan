script   = cpu-fan
service  = cpu-fan.service
conf_fl  = cpu-fan.conf

bin_dir = /usr/local/bin
sys_dir = /usr/lib/systemd/system
etc_dir = /etc

shell   != which zsh || echo /bin/bash
is_zsh  != which zsh
is_bash != which bash

bash_complete = complete.bash
zsh_complete  = complete.zsh

bash_complete_dir = /etc/bash_completion.d
zsh_complete_dir != \
	which zsh >/dev/null && \
	zsh -c 'echo $${(M)fpath:\#*Completion/Unix}'

help:
	@echo
	@echo "syntax: make {install|uninstall}"
	@echo

install: .check_for_zsh .run_as_root .zsh_is_present .empty_echo .install_files
	@systemctl daemon-reload
	@echo

uninstall: .run_as_root .empty_echo .uninstall_files
	@systemctl daemon-reload
	@echo


.empty_echo:
	@echo

.install_files:
	@echo -n "   Installing files ...................... "
	@[ -d ${root_dir}${bin_dir} ] || mkdir -p ${root_dir}${bin_dir}
	@[ -d ${root_dir}${sys_dir} ] || mkdir -p ${root_dir}${sys_dir}
	@cp src/${script}  $(root_dir)${bin_dir}/
	@cp src/${service} $(root_dir)${sys_dir}/
	@[ -z ${is_bash} ] || cp src/${bash_complete} ${root_dir}/${bash_complete_dir}/${script}
	@[ -z ${is_zsh}  ] || cp src/${zsh_complete}  ${root_dir}/${zsh_complete_dir}/_${script}
	@echo DONE

.uninstall_files:
	@echo -n "   Uninstalling files .................... "
	@[ ! -f ${bin_dir}/${script}  ] || rm -f ${bin_dir}/${script}
	@[ ! -f ${sys_dir}/${service} ] || rm -f ${sys_dir}/${service}
	@[ ! -f ${etc_dir}/${conf_fl} ] || rm -f ${etc_dir}/${conf_fl}
	@[ ! -f ${bash_complete_dir}/${script} ] || rm -f ${bash_complete_dir}/${script}
	@[ ! -f ${zsh_complete_dir}/_${script} ] || rm -f ${zsh_complete_dir}/_${script}
	@echo DONE

.zsh_is_present:
	@if [ -z ${is_zsh}  ]; then \
		echo "\e[31m"; \
		echo "   This is zsh scipt but no zsh shell is present"; \
		echo "   on system. Install zsh!"; \
		echo "\e[0m"; \
		exit 1; \
	fi

.run_as_root:
	@if ! [ "$(shell id -u)" = 0 ]; then \
		echo "\e[31m"; \
		echo "   You are not root, run this target as root please!"; \
		echo "\e[0m"; \
		exit 1; \
	fi

.check_for_zsh:
	@if [ "${is_zsh}" = "" ]; then \
		echo "\e[31m"; \
		echo "ZSH shell is not installed on this system! Please install it."; \
		echo "\e[0m"; \
		exit 1; \
	fi

