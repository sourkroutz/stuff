#!/bin/sh

##Variables



##Ensure user is sudo
if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root. Do a sudo su first"
	exit 1
fi

##Update apt and install nessesary programs
apt-get update
apt-get install openvpn unzip -y

##Download PIA OpenVPN files
mkdir /etc/openvpn/pia
cd /etc/openvpn/pia
wget https://www.privateinternetaccess.com/openvpn/openvpn.zip
unzip openvpn.zip 

##This selects what server we will set for autoconnect

prompt="Please select a default PIA server:"
options=( $(find -maxdepth 1 -print0 | xargs -0) )

PS3="$prompt "
select opt in "${options[@]}" "Quit" ; do 
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit

    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "You picked $opt to be your default server"
        break

    else
        echo "Invalid option. Try another one."
    fi
done    

ls -ld $opt

##Changes the server config file to find cradentials
sed -i 's/auth-user-pass/auth-user-pass login.conf/g' $opt

##Prepare OpenVPN config 

echo "Ensure you are using the special generated cridentials"
read -p 'PIA OpenVPn Username: ' username
read -sp 'PIA OpenVPn Password: ' password

echo '$username' > login.conf
echo '$password' > login.conf

#This will set OpenVPN to autostart the selected server
echo "AUTOSTART=$opt" > /etc/default/openvpn
