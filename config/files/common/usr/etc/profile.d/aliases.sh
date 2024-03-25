# Global aliases
if [ -f $HOME/.aliases ]; then
	. $HOME/.aliases
fi

# Host only aliases
if [ ! -e /run/.containerenv ] && [ ! -e /.dockerenv ]; then
	if [ -f $HOME/.aliases-host-only ]; then
		. $HOME/.aliases-host-only
	fi
	
# Container only aliases
else
	if [ -f $HOME/.aliases-container-only ]; then
		. $HOME/.aliases-container-only
	fi
fi