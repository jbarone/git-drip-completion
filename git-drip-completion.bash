#!bash
#
# git-drip-completion
# ===================
#
# Bash completion support for [git-drip](http://github.com/jbarone/gitdrip)
#
# The contained completion routines provide support for completing:
#
#  * git-drip init and version
#  * feature, hotfix and release branches
#  * remote feature, hotfix and release branch names
#
#
# Installation
# ------------
#
# To achieve git-drip completion nirvana:
#
#  0. Install git-completion.
#
#  1. Install this file. Either:
#
#     a. Place it in a `bash-completion.d` folder:
#
#        * /etc/bash-completion.d
#        * /usr/local/etc/bash-completion.d
#        * ~/bash-completion.d
#
#     b. Or, copy it somewhere (e.g. ~/.git-drip-completion.sh) and put the following line in
#        your .bashrc:
#
#            source ~/.git-drip-completion.sh
#
#  2. If you are using Git < 1.7.1: Edit git-completion.sh and add the following line to the giant
#     $command case in _git:
#
#         drip)        _git_drip ;;

_git_drip ()
{
	local subcommands="init feature release hotfix help version"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	init)
		__git_drip_init
		return
		;;
	feature)
		__git_drip_feature
		return
		;;
	release)
		__git_drip_release
		return
		;;
	hotfix)
		__git_drip_hotfix
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

__git_drip_init ()
{
	local subcommands="help"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi
}

__git_drip_feature ()
{
	local subcommands="list start finish publish track diff rebase co checkout pull delete help"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	pull)
		__gitcomp "$(__git_remotes)"
		return
		;;
	co|checkout|finish|diff|rebase|delete)
		__gitcomp "$(__git_drip_list_branches 'feature')"
		return
		;;
	publish)
		__gitcomp "$(comm -23 <(__git_drip_list_branches 'feature') <(__git_drip_list_remote_branches 'feature'))"
		return
		;;
	track)
		__gitcomp "$(comm -23 <(__git_drip_list_remote_branches 'feature') <(__git_drip_list_branches 'feature'))"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

__git_drip_release ()
{
	local subcommands="list start finish track publish help"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	finish)
		__gitcomp "$(__git_drip_list_branches 'release')"
		return
		;;
	publish)
		__gitcomp "$(comm -23 <(__git_drip_list_branches 'release') <(__git_drip_list_remote_branches 'release'))"
		return
		;;
	track)
		__gitcomp "$(comm -23 <(__git_drip_list_remote_branches 'release') <(__git_drip_list_branches 'release'))"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac

}

__git_drip_hotfix ()
{
	local subcommands="list start finish track publish help"
	local subcommand="$(__git_find_on_cmdline "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	finish)
		__gitcomp "$(__git_drip_list_branches 'hotfix')"
		return
		;;
	publish)
		__gitcomp "$(comm -23 <(__git_drip_list_branches 'hotfix') <(__git_drip_list_remote_branches 'hotfix'))"
		return
		;;
	track)
		__gitcomp "$(comm -23 <(__git_drip_list_remote_branches 'hotfix') <(__git_drip_list_branches 'hotfix'))"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

__git_drip_prefix ()
{
	case "$1" in
	feature|release|hotfix)
		git config "gitdrip.prefix.$1" 2> /dev/null || echo "$1/"
		return
		;;
	esac
}

__git_drip_list_branches ()
{
	local prefix="$(__git_drip_prefix $1)"
	git branch --no-color 2> /dev/null | tr -d ' |*' | grep --color=never "^$prefix" | sed s,^$prefix,, | sort
}

__git_drip_list_remote_branches ()
{
	local prefix="$(__git_drip_prefix $1)"
	local origin="$(git config gitdrip.origin 2> /dev/null || echo "origin")"
	git branch --no-color -r 2> /dev/null | sed "s/^ *//g" | grep --color=never "^$origin/$prefix" | sed s,^$origin/$prefix,, | sort
}

# alias __git_find_on_cmdline for backwards compatibility
if [ -z "`type -t __git_find_on_cmdline`" ]; then
	alias __git_find_on_cmdline=__git_find_subcommand
fi
