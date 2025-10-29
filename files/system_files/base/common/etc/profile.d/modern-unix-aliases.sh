# Aliases for modernized versions of common Linux tools

# bat for cat
alias cat='bat --theme=ansi --style=plain --pager=never'

# eza for ls & tree
alias ls='eza'
alias ll='eza -lHbg --group-directories-first'
alias la='eza -lHbgaa --group-directories-first'
alias tree='eza --tree'
