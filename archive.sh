#!/bin/bash
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "# archive.sh [<directory_name>, default is current working directory] [<older than>, default is one day] [--delete, -d <filenames ...>] [--help, -h]"
	echo "Example of usage: <command> #[explanation]"
	echo "# archive.sh # archiving current working directory files modified more than one day ago"
	echo "# archive.sh Documents # archiving files in Documents directory modified more than one day ago"
	echo "# archive.sh Pictures 4 # archiving files in Pictures directory modified more than four days ago"
	echo "# archive.sh Music-2019-09-19-15-25-42.tar.gz --delete a.mp3 b.mp3 # deleting two mp3 files from Music-2019-09-19-15-25-42.tar.gz archive"
	exit 0;
fi
# by default, directory to archive is current one
directory_name=$(pwd)
next_index=1
# if number of arguments bigger than one and the first argument is valid directory name
if [ $# -ge 1 ] && [ -d $1 ]; then
	directory_name=$1
	next_index=2
fi
if [ $# -eq 1 ] && [ "${!next_index}" = "--delete" -o "${!next_index}" = "-d" ]; then
	echo "You have to specify on which archive use delete option. Refer to --help information.";
	exit 0;
fi
# if number of arguments bigger than two and the second argument is the delete option
if [ $# -gt 2 ] && [ "$2" = "--delete" -o "$2" = "-d" ]; then
# https://unix.stackexchange.com/a/80252
	pigz -d < $1 | tar -f - --delete "${@:3}" | pigz > updated-"$1".tar.gz
	exit 0
fi
older_than=1
if [ $next_index -eq $# ]; then
	older_than=${!next_index}
fi
archive_name="$1-$(date +"%Y-%m-%d-%H-%M-%S")"
# https://stackoverflow.com/a/23357277
files=()
while read -r -d $'\0'; do files+=("$REPLY")
done < <(find $1 -type f -ctime +$older_than -print0)
tar -czvf ${archive_name}.tar.gz "${files[@]}"
exit 0
