# Aliases

# Global aliases
if [ -f ~/.aliases ]; then
	. ~/.aliases
fi

# Host only aliases
if [ ! -e /run/.containerenv ] && [ ! -e /.dockerenv ]; then
	if [ -f ~/.aliases-host-only ]; then
		. ~/.aliases-host-only
	fi
	
# Container only aliases
else
	if [ -f ~/.aliases-container-only ]; then
		. ~/.aliases-container-only
	fi
fi