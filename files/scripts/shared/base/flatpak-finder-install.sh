#!/usr/bin/env bash

# Installs 'fp' ('flatpak finder') - simplifies working with Flatpak in CLI
# Source: https://github.com/DLopezJr/fp

set -euo pipefail

SCRIPT="/usr/bin/fp"

echo "Installing 'fp' ('flatpak finder') to simplify working with Flatpak in CLI"

cat << 'EOF' > ${SCRIPT}
#!/bin/bash
# flatpak-finder: Script that allows you to specify any part of a Flatpak name/appID rather than the full thing.
# Syntax is exactly the same as flatpak itself.
#
# Created by TDGalea, last updated 2024-11-13 01:25 (and now to run to sleep).
# Huge thanks to Honest_Photograph519 on Reddit for the FAR better searching method - I really need to get into arrays more.
shopt -s nocasematch

# Store intent (run, override, etc.) in $mode if passed.
[[ -z $1 ]] && printf "What do you want to do?\n" >&2 && exit 2
mode=$1
shift

# If we have a name passed, do the search fiasco. Otherwise we can skip it (and probably be told off by Flatpak).
if [[ ! -z $1 ]]; then
	pattern=$1
	shift

	# Store the rest of the arguments in $args.
	args="$@"

	# Shove all the installed Flatpaks into $paks.
	readarray -t paks < <(flatpak list --columns=name,application)

	# Find what Flatpaks match the given pattern.
	for pak in "${paks[@]}"; do
		IFS=$'\t' read name appid <<<"$pak"
		[[ $name =~ $pattern ]] || [[ $appid =~ $pattern ]] && {
			matching_paks+=( "$appid" )
			printf "Found '$name' ('$appid')\n"
		}
	done

	# Check how many results we have.
	if [[ ${#matching_paks[@]} -gt 1 ]]; then
		# More than one - go interactive if we can.
		[[ ! -t 0 ]] && {
			# We're not in a terminal, so we can't go interactive. Try sending a notification, then exit.
			notify-send "Flatpak Finder" "Too many results (${#matching_paks[@]}).\nPlease be a bit more specific, or run in a terminal to select interactively."
			exit 1
		}
		clear

		# Trap CTRL+C so that we can return the terminal to normal.
		function fq {
			tput cnorm
			exit 2
		}
		trap 'fq' SIGHUP SIGINT SIGTERM

		# Check terminal height, and request user to resize if it is too low.
		function checkTermHeight {
			while [[ $(tput lines) -lt $(expr ${#matching_paks[@]} + 3) ]]; do
				printf "Terminal not tall enough!\n"
				printf "Currently $(tput lines) lines - need $(expr ${#matching_paks[@]} + 3).\n"
				printf "Resize now, or use CTRL+C to exit.\n"
				sleep 1
				clear
			done
		}

		# We need an escape code to capture the arrow keys.
		esc=$(printf "\u1b")
		# Hide the terminal cursor.
		tput civis

		selection=1
		# Loop until an option is chosen.
		while [[ -z $choice ]]; do
			clear
			# Make sure the terminal is tall enough to display all the options.
			checkTermHeight

			printf "Select a Flatpak from the list below, or use 'q' to quit.\n\n"
			x=1
			# Print all the options.
			for pak in ${matching_paks[@]}; do
				IFS=$'\t' read appid <<<"$pak"
				printf " "
				# If the current option is the highlighted one, invert text colour.
				[[ $x -eq $selection ]] && printf "\e[30;47m"
				# Print this option's package name.
				printf " $appid\e[0m\n"
				let x+=1
			done

			unset input
			# Take user input.
			read -rsn1 input; [[ $input == $esc ]] && read -rsn2 input
			case $input in
				 'q') fq;;
				'[A') [[ $selection -gt 1 ]] && let selection-=1 || selection=${#matching_paks[@]};; # Up arrow - go up by decreasing the selection var, unless we're at the top, in which case make it the value of matching flatpaks.
	 			'[B') [[ $selection -lt ${#matching_paks[@]} ]] && let selection+=1 || selection=1;; # Down arrow - go down by increasing the selection var, unless we're at the bottom, in which case make it 1.
	 			'[C') selection=${#matching_paks[@]};; # Right arrow - select last item.
				'[D') selection=1;; # Left arrow - Select first item.
				   *) [[ $input = "" ]] && choice=$selection;; # Enter or space will select an item, otherwise do nothing.
			esac
		done

		# Something's been selected - figure out which one it was.
		x=1
		for pak in ${matching_paks[@]}; do
			IFS=$'\t' read appid <<<"$pak"
			[[ $x -eq $choice ]] && target=$appid
			let x+=1
		done
		tput cnorm
		printf "\n"
	elif [[ ${#matching_paks[@]} -lt 1 ]]; then
		# No results at all.
		printf "No results found. If the Flatpak is installed, please check your spelling.\n"
		exit 1
	else
		# Just right.
		target="$matching_paks"
	fi
fi

# Run or override the found flatpak then preserve the exit code.
flatpak $mode "$target" $@; exit $?
EOF

chmod +x ${SCRIPT}
