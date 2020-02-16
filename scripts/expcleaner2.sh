#!/bin/bash
datenow=$(date +%s)
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%45s%-10s%-5s\n' "Paveluotas saskaitos pasalinimas" ""
printf '%-20s%-25s%-20s\n' "Vartotojas" "Galiojimo laikas" "Estado / Veiksmas" ; echo "" ; tput sgr0
for user in $(awk -F: '{print $1}' /etc/passwd); do
	expdate=$(chage -l $user|awk -F: '/Paskyros galiojimo laikas baigiasi/{print $2}')
	echo $expdate|grep -q never && continue
	datanormal=$(date -d"$expdate" '+%d/%m/%Y')
	tput setaf 3 ; tput bold ; printf '%-20s%-21s%s' $user $datanormal ; tput sgr0
	expsec=$(date +%s --date="$expdate")
	diff=$(echo $datenow - $expsec|bc -l)
	tput setaf 2 ; tput bold
	echo $diff|grep -q ^\- && echo "aktyvus (nepasalintas)" && continue
	tput setaf 1 ; tput bold
	echo "Pasibaiges (pasalintas)"
	pkill -f $user
	userdel $user
	grep -v ^$user[[:space:]] /root/usuarios.db > /tmp/ph ; cat /tmp/ph > /root/usuarios.db
done
tput sgr0 
echo ""
