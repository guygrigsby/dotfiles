export LSCOLORS="Gxfxcxdxbxegedabagacad"

v_mode=""

PROMPT='%{$fg[magenta]%}['
#PROMPT+=' %{$fg[cyan]%}%1~%{$reset_color%} $(git_prompt_info)'
PROMPT+='%{$fg_bold[white]%}$(shorty)%{$reset_color%}'
PROMPT+='%{$fg[magenta]%}]'
PROMPT+='%{$fg_bold[white]%} $(git_prompt_info) '
PROMPT+='%{$reset_color%}'


function shorty () {
	tl="~"
	hp="$HOME"
	with_tilde=${PWD/$hp/$tl}
	paths=(${(s:/:)with_tilde})

	short_path=''
	for dir in ${paths[@]}
	do
		short_path+="${dir:0:1}/"
	done

	echo ${short_path:0:-1}
}

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[magenta]%}[%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}%{$fg[magenta]%}]%{$fg_bold[yellow]%} ➜"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}%{$fg[magenta]%}] ➜"

ZSH_THEME_GIT_PROMPT_CACHE="true"

#RPROMPT='%{$fg[cyan]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

