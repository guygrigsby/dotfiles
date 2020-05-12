export LSCOLORS="Gxfxcxdxbxegedabagacad"

v_mode=""

PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
#PROMPT+=' %{$fg[cyan]%}%1~%{$reset_color%} $(git_prompt_info)'
PROMPT+=' %{$fg[cyan]%}$(shorty)%{$reset_color%} $(git_prompt_info)'


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

	print ${short_path:0:-1}
}

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[magenta]%}[%{$fg[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[magenta]%}] %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[magenta]%}]"

ZSH_THEME_GIT_PROMPT_CACHE="true"

#RPROMPT='%{$fg[cyan]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

