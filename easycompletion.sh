# letters used to label each file
_easyComp_LABELS=(d h t n s a o e u i 1 2 3 4 7 8 9 0) # Dvorak
# _easyComp_LABELS=(h j k l a s d f g 1 2 3 4 7 8 9 0) # QWERTY

# displays the label for the next file
_easyComp_counter() {
	local NKEYS=${#_easyComp_LABELS[@]}
	local cnt=$1
	label=${_easyComp_LABELS[$(($cnt % $NKEYS))]}
	cnt=$(($cnt / ${NKEYS}))
	while [ $cnt -ne 0 ]; do
		label=${_easyComp_LABELS[$(($cnt % $NKEYS))]}$label
		cnt=$(($cnt / ${NKEYS}))
	done
	echo $label
}

# set COMPREPLY content
#
# usage:
# _easyComp_genList [fileNamePrefix] [selectionLabel]
_easyComp_genList() {
	COMPREPLY=($(compgen -o default "$1" | grep -E "^${1//./\\.}"))

	# If there is only one candidate, use it
	if [ ${#COMPREPLY[@]} -le 1 ]; then
		return
	fi

	# set label for each candidate
	cnt=0
	COMPREPLY=($(
	for x in "${COMPREPLY[@]}"; do 
		# escape chacacters
		x=$(printf %q "$x")
		label=$(_easyComp_counter $cnt)
		# show all candidates or selected one
		if [ "$2" = "" ]; then
			# make labels upper case
			echo -e "${label^^}: $x"
		elif [ "$label" = "$2" ] ;then 
			echo "$x"
			break
		fi
		cnt=$(($cnt + 1))
	done
	))
}

_easyComp() {
	base=$(echo "$2" | sed "s/\*\*/\t/")
	prefix=$(echo -e "$base" | cut -f 1) # before **
	selection=$(echo -e "$base" | cut -f 2) # text label (after **)

	# if ** is not included, do nothing
	if [ "$base" = "$2" ]; then
		return
	fi

	# completion
	BK_IFS=$IFS
	IFS=$'\n'
	_easyComp_genList "$prefix" "$selection"
	IFS=$BK_IFS
}

# commands use this completion
complete -o default -F _easyComp mv
complete -o default -F _easyComp cp
complete -o default -F _easyComp cd
complete -o default -F _easyComp rm
complete -o default -F _easyComp lv
complete -o default -F _easyComp l
complete -o default -F _easyComp ls
complete -o default -F _easyComp less
complete -o default -F _easyComp cat
complete -o default -F _easyComp file
complete -o default -F _easyComp unzip
complete -o default -F _easyComp xdg-open
