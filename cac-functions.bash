####################
## BUILD A NEW VM ##
####################

build () 
{
	mapfile -t stats < <(curl -s -k "${url}${uri[resources]}?key=${KEY}&login=${LOGIN}" | sed -e 's/{/\n/g' -e 's/\}//g' | grep -i cpu)
	totcpu=$(echo "${stats[0]}" | cut -d\" -f4)
	totram=$(echo "${stats[0]}" | cut -d\" -f8)
	totdisk=$(echo "${stats[0]}" | cut -d\" -f12)
	uscpu=$(echo "${stats[1]}" | cut -d\" -f4)
	usram=$(echo "${stats[1]}" | cut -d\" -f8)
	usdisk=$(echo "${stats[1]}" | cut -d\" -f12)
	read -p "cpu, $(echo $totcpu - $uscpu | bc) available: " cpu
	read -p "ram, $(echo $totram - $usram | bc) available: " ram
	read -p "storage, $(echo $totdisk - $usdisk | bc) available: " storage
	os=27  #This sets it to ubuntu, use templates function for list.
	curl -s -k --data "key=${KEY}&login=${LOGIN}&cpu=${cpu}&ram=${ram}&storage=${storage}&os=${os}" "${url}${uri[build]}"
}


##################################
## LIST STATUS OF QUEUE AND VMs ##
##################################

list ()
{
curl -s -k "${url}${uri[list]}?key=${KEY}&login=${LOGIN}" | sed -e 's/{/\n/g' -e 's/\}//g'
echo ## Add a newline
}


############################################################
## OFFER THE USER A LIST OF VMS TO SELECT AND THEN DELETE ##
############################################################

delete ()
{
	select server in $(list() | grep -v listservers | sed -e 's/"sid":"//g' -e 's/".*label":"/-name:/g' -e 's/".*//g')
	do
	echo "You chose $server"
	break
	done
	sid="$(echo ${server%-*})"
	curl -s -k --data "key=${KEY}&login=${LOGIN}&sid=${sid}" "${url}${uri[delete]}"
}


###############################################
## CHECK A VM AND THEN RESET IT IF NECESSARY ##
###############################################

reset ()
{
	sid=""
	ansuser=""
	domain=""
	while true
	do
	   if ansible "$domain" -m ping -u "$ansuser" &>/dev/null
	   then
	      echo "$domain looks up from here, doing nothing."
	      sleep 3600
	   else
	      echo "$domain appears to be down, trying to reset."
	      if curl -s -o /dev/null -k --data "key=${KEY}&login=${LOGIN}&sid=${sid}&action=reset" "${url}${uri[powerop]}"
	      then
		 echo "Reset appears to have worked, waiting 5 minutes."
		 sleep 300
	      else
		 echo "Reset failed."
		 sleep 300
	      fi
	   fi
	done
}


#########################################
## LIST AVAILABLE OSs FOR BUILDING VMs ##
#########################################

templates ()
{
curl -s -k "${url}${uri[templates]}?key=${KEY}&login=${LOGIN}" | sed -e 's/{/\n/g' -e 's/\}//g'
}
