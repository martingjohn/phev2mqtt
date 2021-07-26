#!/usr/bin/with-contenv bashio

#Cant seem to work out why it's crashing out, so turning off pipefail
set +e

export phev_ssid="$(bashio::config 'phev_ssid')"
export phev_password="$(bashio::config 'phev_password')"
export client_mac="$(bashio::config 'client_mac')"
export wlan="$(bashio::config 'wlan')"
export debug="$(bashio::config 'debug')"

if [[ $debug == "true" ]]
then
	echo Debug mode on - sleeping indefinitely
	sleep inf
fi

#Check interface exists
iwconfig "${wlan}"
if [[ $? -ne 0 ]]
then
	echo Wifi "${wlan}" does not exist
	exit 1
fi

#Bounce interface
ip link set dev "${wlan}" down
ip link set dev "${wlan}" up

sleep 10

#Set MAC address
echo Setting MAC address
ip link set dev "${wlan}" address "${client_mac}"

#Check to see if the ssid is already configured
echo Checking to see if SSID "${phev_ssid}" is alredy configured
SSID_CONFIG=$(iwconfig "${wlan}" | grep "${phev_ssid}" | wc -l)
if [[ "${SSID_CONFIG}" -ne 1 ]]
then

	#Check to see if the ssid is available
	echo Checking to see if SSID "${phev_ssid}" is available
	SSID_PRESENT=$(iwlist "${wlan}" scanning | grep "${phev_ssid}" | wc -l)

	if [[ "${SSID_PRESENT}" -ne 1 ]]
	then
		echo Cant find "${phev_ssid}" - "${SSID_PRESENT}"
		exit 1
	fi

	#Associate wlan to ssid
	echo Associate wlan to ssid
	iwconfig "${wlan}" essid "${phev_ssid}"

	#Check it's configured
	echo Check it configured correctly
	SSID_CONFIG2=$(iwconfig "${wlan}" | grep "${phev_ssid}" | wc -l)

	if [[ "${SSID_CONFIG2}" -ne 1 ]]
	then
		echo Wlan not configured - "${SSID_CONFIG}"
		exit 1
	fi

fi

#Create a wpa_supplicant configuration stanza for the wireless access point.
echo Create wpa_supplicant configuration
wpa_passphrase "${phev_ssid}" "${phev_password}" > /etc/wpa_supplicant/wpa_supplicant.conf

#Start wpa_supplicant in the foreground to make sure the connection succeeds.
#wpa_supplicant -i "${wlan}" -c /etc/wpa_supplicant/wpa_supplicant.conf

#If all is well, run it as a daemon in the background by setting the -B option.
echo Start wpa_supplicant
wpa_supplicant -B -i "${wlan}" -c /etc/wpa_supplicant/wpa_supplicant.conf

#Configure the interface with an IP address.
echo Fetch DHCP IP address
udhcpc -i "${wlan}"

#Wait for it to come up
echo Sleeping for a minute
sleep 60

#Sanity check: the interface should have an inet address.
echo Check we are on the right subnet
NETWORK=$(ip addr show "${wlan}" | awk '$1=="inet" {print $2}' | cut -d. -f1,2,3)
if [[ "${NETWORK}" != "192.168.8" ]]
then
        echo Not on right subnet - "${NETWORK}"
	exit 1
fi

echo All setup

sleep inf

exit

