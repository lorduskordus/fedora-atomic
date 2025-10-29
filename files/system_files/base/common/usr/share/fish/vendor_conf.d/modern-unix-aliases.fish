# Aliases for modernized versions of common Linux tools

# bat for cat
if type -q bat
    alias cat='bat --theme=ansi --style=plain --pager=never'
end

# eza for ls & tree
if type -q eza
    alias ls='eza'
    alias ll='eza -lHbg --group-directories-first'
    alias la='eza -lHbgaa --group-directories-first'
    alias tree='eza --tree'
end
