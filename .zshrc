ZSH=$HOME/.oh-my-zsh
ZSH_CONFIG=$HOME/.oh-my-zsh-config
DISABLE_AUTO_UPDATE="true"
HIST_STAMPS="dd.mm.yyyy"
plugins=(gitfast pep8 common-aliases dirhistory django docker httpie last-working-dir perms pip pyenv python screen systemd virtualenvwrapper)
ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh
source $ZSH_CONFIG/themes/zsh-theme-powerlevel9k/powerlevel9k.zsh-theme


#POWERLEVEL9K_MODE="awesome-patched"
POWERLEVEL9K_MODE="awesome-fontconfig"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh context dir virtualenv vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time status_joined time)

POWERLEVEL9K_PROMPT_ON_NEWLINE=true

#POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND=075
POWERLEVEL9K_VIRTUALENV_BACKGROUND=077

#POWERLEVEL9K_TIME_BACKGROUND=black
#xPOWERLEVEL9K_TIME_FOREGROUND=grey


POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=black
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=green

#POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON="\uE266" #      


#POWERLEVEL9K_EXECUTION_TIME_ICON="\U0231B"

POWERLEVEL9K_STATUS_VERBOSE=false

POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3

POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S %d.%m}"



#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="\n"
#POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX="$(prompt_context "left" 1)$(left_prompt_end)"


source $ZSH_CONFIG/themes/zsh-theme-powerlevel9k/powerlevel9k.zsh-theme



alias nano='nano -W -m -w'


#Aliases from grml-zsh-config

alias 'dus=du -sckx * | sort -nr'
alias insecssh='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'


# Set SSH to use gpg-agent
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
fi

export PATH=~/.local/bin/:$PATH

unalias gcf
function gcf (){
	NUMBER=$1
	if [[ -z ${NUMBER} ]]
	then
		echo "Please enter feature number"
		return
	fi
	BRANCHES=$(git branch --list | grep feature/${NUMBER}_)
	DESIRED_INDEX=1
	BRANCHES_AMOUNT=$(wc -l <<< "$BRANCHES")
	REMOTE_BRANCHES=$(git branch --list -r | grep feature/${NUMBER}_)
	REMOTE_BRANCHES_AMOUNT=$(wc -l <<< "$REMOTE_BRANCHES")
	if [[ -z ${BRANCHES} ]] && [[ -z ${REMOTE_BRANCHES} ]]
	then
		echo "No feature-branch available with ${NUMBER}"
		return
	fi

	if [[ -n ${BRANCHES} ]]
	then
		if ! [[ ${BRANCHES_AMOUNT} -eq 1 ]]
		then	
			echo "Choose desired branch:"
			echo "$(grep -n . <<< ${BRANCHES})"
			read DESIRED_INDEX
			if ! [[ "${DESIRED_INDEX}" =~ ^[0-9]+$ ]]
				then
					DESIRED_INDEX=1
				fi
			if [[ ${DESIRED_INDEX} -gt ${BRANCHES_AMOUNT} ]]
				then
					echo "Wrong input"
					return
				fi
			BRANCH=$(head -n ${DESIRED_INDEX} <<< "${BRANCHES}"  | tail -n 1 )
		else
			BRANCH=${BRANCHES}
		fi

		BRANCH=$(sed 's/^[ ]*//'<<<${BRANCH})
		git checkout ${BRANCH}
	fi	

	if [[ -z ${BRANCHES} ]] && [[ -n ${REMOTE_BRANCHES} ]]
	then
		if ! [[ ${REMOTE_BRANCHES_AMOUNT} -eq 1 ]]
		then	
			echo "Choose desired remote branch:"
			echo "$(grep -n . <<< ${REMOTE_BRANCHES})"
			read DESIRED_INDEX
			if ! [[ "${DESIRED_INDEX}" =~ ^[0-9]+$ ]]
				then
					DESIRED_INDEX=1
				fi
			if [[ ${DESIRED_INDEX} -gt ${REMOTE_BRANCHES_AMOUNT} ]]
				then
					echo "Wrong input"
					return
				fi
			REMOTE_BRANCH=$(head -n ${DESIRED_INDEX} <<< "${REMOTE_BRANCHES}"  | tail -n 1 )
		else
			REMOTE_BRANCH=${REMOTE_BRANCHES}
		fi
		REMOTE_BRANCH_NAME=$(sed 's/^[ ]*//'<<<${REMOTE_BRANCH})
		BRANCH_NAME=$(echo ${REMOTE_BRANCH_NAME} | cut -d '/' -f 2-)
		git checkout -b ${BRANCH_NAME} ${REMOTE_BRANCH_NAME}
	fi
}


function islinux () {
    [[ $GRML_OSTYPE == "Linux" ]]
}

function isfreebsd () {
    [[ $GRML_OSTYPE == "FreeBSD" ]]
}

function bk () {
    emulate -L zsh
    local current_date=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
    local clean keep move verbose result all to_bk
    setopt extended_glob
    keep=1
    while getopts ":hacmrv" opt; do
        case $opt in
            a) (( all++ ));;
            c) unset move clean && (( ++keep ));;
            m) unset keep clean && (( ++move ));;
            r) unset move keep && (( ++clean ));;
            v) verbose="-v";;
            h) <<__EOF0__
bk [-hcmv] FILE [FILE ...]
bk -r [-av] [FILE [FILE ...]]
Backup a file or folder in place and append the timestamp
Remove backups of a file or folder, or all backups in the current directory

Usage:
-h    Display this help text
-c    Keep the file/folder as is, create a copy backup using cp(1) (default)
-m    Move the file/folder, using mv(1)
-r    Remove backups of the specified file or directory, using rm(1). If none
      is provided, remove all backups in the current directory.
-a    Remove all (even hidden) backups.
-v    Verbose

The -c, -r and -m options are mutually exclusive. If specified at the same time,
the last one is used.

The return code is the sum of all cp/mv/rm return codes.
__EOF0__
return 0;;
            \?) bk -h >&2; return 1;;
        esac
    done
    shift "$((OPTIND-1))"
    if (( keep > 0 )); then
        if islinux || isfreebsd; then
            for to_bk in "$@"; do
                cp $verbose -a "${to_bk%/}" "${to_bk%/}_$current_date"
                (( result += $? ))
            done
        else
            for to_bk in "$@"; do
                cp $verbose -pR "${to_bk%/}" "${to_bk%/}_$current_date"
                (( result += $? ))
            done
        fi
    elif (( move > 0 )); then
        while (( $# > 0 )); do
            mv $verbose "${1%/}" "${1%/}_$current_date"
            (( result += $? ))
            shift
        done
    elif (( clean > 0 )); then
        if (( $# > 0 )); then
            for to_bk in "$@"; do
                rm $verbose -rf "${to_bk%/}"_[0-9](#c4,)-(0[0-9]|1[0-2])-([0-2][0-9]|3[0-1])T([0-1][0-9]|2[0-3])(:[0-5][0-9])(#c2)Z
                (( result += $? ))
            done
        else
            if (( all > 0 )); then
                rm $verbose -rf *_[0-9](#c4,)-(0[0-9]|1[0-2])-([0-2][0-9]|3[0-1])T([0-1][0-9]|2[0-3])(:[0-5][0-9])(#c2)Z(D)
            else
                rm $verbose -rf *_[0-9](#c4,)-(0[0-9]|1[0-2])-([0-2][0-9]|3[0-1])T([0-1][0-9]|2[0-3])(:[0-5][0-9])(#c2)Z
            fi
            (( result += $? ))
        fi
    fi
    return $result
}

