# Aliases for modernized versions of common Linux tools

# bat for cat
if command -v bat &> /dev/null; then
    alias cat='bat --theme=ansi --style=plain --pager=never'
fi

# eza for ls & tree
if command -v eza &> /dev/null; then
    alias ls='eza'
    alias ll='eza -lHbg --group-directories-first'
    alias la='eza -lHbgaa --group-directories-first'
    alias tree='eza --tree'
fi
