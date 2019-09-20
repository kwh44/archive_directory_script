#!/bin/bash

print_help_info () {
	echo "# archive.sh [<directory_name>, default is current working directory] [<older than>, default is one day] [--delete, -d <filenames ...>] [--help, -h]"
	echo "Example of usage: <command> #[explanation]"
	echo "# archive.sh # archiving current working directory files modified more than one day ago"
	echo "# archive.sh Documents # archiving files in Documents directory modified more than one day ago"
	echo "# archive.sh Pictures 4 # archiving files in Pictures directory modified more than four days ago"
	echo "# archive.sh Music-2019-09-19-15-25-42.tar.gz --delete a.mp3 b.mp3 # deleting two mp3 files from Music-2019-09-19-15-25-42.tar.gz archive"
	return 0;
}

delete_files_from_tgz () {
	pigz -d < $1 | tar -f - --delete "${@:3}" | pigz > updated.tar.gz
	return 0
}

create_tgz () {
	directory_name=$(pwd)
	next_index=1
	if [ $# -ge 1 ] && [ -d $1 ]; then
		directory_name=$1
		next_index=2
	fi
	older_than=1
	if [ $next_index -eq $# ]; then
		older_than=${!next_index}
	fi
	files=()
	while read -r -d $'\0'; do files+=("$REPLY")
	done < <(find $directory_name -type f -ctime +$older_than -print0)
	archive_name="$directory_name-$(date +"%Y-%m-%d-%H-%M-%S")"
	tar -czvf ${archive_name}.tar.gz "${files[@]}"
	return 0
}

main () {
	if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
		print_help_info
	elif [ $# -gt 2 ] && [ "$2" = "--delete" -o "$2" = "-d" ] && [ -f $1 ]; then
		delete_files_from_tgz "$@"
	else
		create_tgz "$@"
	fi
	return 0
}

main "$@"
exit 0
