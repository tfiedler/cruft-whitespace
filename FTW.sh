cd /usr/share/cowsay/cows;while(:)do clear;R=`perl -e'printf("%1d",rand($ARGV[0]+1))' $(ls -1|wc -l)`;fortune|cowsay -f$(echo *|cut -d' ' -f${R});sleep 9;done
