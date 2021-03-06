#!/bin/bash
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%33s%s%-12s\n' "Pakeisti galiojimo data" ; tput sgr0
echo ""
tput bold ; echo "Vartotoju sarasas ir galiojimo laikas:" ; tput sgr0
echo ""
tput setaf 3 ; tput bold 
awk -F : '$3 >= 500 { print $1 }' /etc/passwd | grep -v '^nobody' | while read user
  do
	expire="$(chage -l $user | grep -E "Account expires" | cut -d ' ' -f3-)"
	if [[ $expire == "never" ]]
	then
		nunca="Nunca"
		printf '  %-30s%s\n' "$user" "Nunca"
	else
		databr="$(date -d "$expire" +"%Y%m%d")"
		hoje="$(date -d today +"%Y%m%d")"
		if [ $hoje -ge $databr ]
		then
			datanormal="$(date -d"$expire" '+%d/%m/%Y')"
			printf '  %-30s%s' "$user" "$datanormal" ; tput setaf 1 ; tput bold ; echo " (Pasibaige)" ; tput setaf 3
			echo "exp" > /tmp/exp
		else
			datanormal="$(date -d"$expire" '+%d/%m/%Y')"
			printf '  %-30s%s\n' "$user" "$datanormal"
		fi
	fi
  done
tput sgr0
echo ""
if [ -a /tmp/exp ]
then
	tput setaf 2 ; tput bold ; echo "Noredami pasalinti visus pasibaigusius vartotojus naudokite komanda: expcleaner" ; echo "" ; tput sgr0
	rm /tmp/exp
fi
read -p "Vartotojo vardas jei norite pakeisti galiojimo laika: " usuario
if [[ -z $usuario ]]
then
	echo ""
	tput setaf 7 ; tput setab 4 ; tput bold ; echo "Ivedete tuscia ar netinkamą vartotojo varda!" ; tput sgr0
	echo ""
	exit 1
else
	if [[ `grep -c /$usuario: /etc/passwd` -ne 0 ]]
	then
		read -p "Iveskite nauja galiojimo data (DIE/MÊN/MET): " inputdate
		sysdate="$(echo "$inputdate" | awk -v FS=/ -v OFS=- '{print $3,$2,$1}')"
		if (date "+%Y-%m-%d" -d "$sysdate" > /dev/null  2>&1)
		then
			if [[ -z $inputdate ]]
			then
				echo ""
				tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Ivedete netinkama arba neegzistuojancia data!" ; echo "Iveskite galiojancia data formatu DIE/MÊN/MET" ; echo "Pavyzdziui: 21/04/2018" ; tput sgr0
				echo ""
				exit 1	
			else
				if (echo $inputdate | egrep [^a-zA-Z] &> /dev/null)
				then
					today="$(date -d today +"%Y%m%d")"
					timemachine="$(date -d "$sysdate" +"%Y%m%d")"
					if [ $today -ge $timemachine ]
					then
						echo ""
						tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Ivedete praeita datą arba dabartine diena!" ; echo "Iveskite galiojancia data formatu DIE/MÊN/MET" ; echo "Pavyzdziui: 21/04/2018" ; tput sgr0
						echo ""
						exit 1
					else
						chage -E $sysdate $usuario
						echo ""
						tput setaf 7 ; tput setab 1 ; tput bold ; echo "Vartotojo galiojimo laikas $usuario buvo pakeistas i: $inputdate" ; tput sgr0
						echo ""
						exit 1
					fi
				else
					echo ""
					tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Ivedete netinkama arba neegzistuojancia data!" ; echo "Iveskite galiojancia data formatu DIE/MÊN/MET" ; echo "Pavyzdziui: 21/04/2018" ; tput sgr0
					echo ""
					exit 1
				fi
			fi
		else
			echo ""iveskite galiojancia data formatu  DIE/MÊN/MET" ; echo "Pavyzdziui:
			tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Ivedete netinkama arba neegzistuojancia data!" ; echo "D 21/04/2018" ; tput sgr0
			echo ""
			exit 1
		fi
	else
		echo " "
		tput setaf 7 ; tput setab 4 ; tput bold ;	echo "Vartotojas $usuario neegzistuoja!" ; tput sgr0
		echo " "
		exit 1
	fi
fi
