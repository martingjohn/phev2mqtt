This is to setup local wifi to connect to Outlander PHEV

Once installed as a local addon, you can configure the Outlander SSID, password, client MAC address (from phone that's previously connected using the official app) and then configure the WiFi to connect to the Outlander via the GUI

NOTE - this will need to keep running in order to keep the IP address

These files need to go in a directory (called phev_setup for example) in the local addons.

If you ssh into the main os, this will be in /usr/share/hassio/addons/local/phev_setup
If you ssh in using the terminal add on, this will be /addons/phev (or symblink /root/addons/phev_setup)
If you connect to the hassio_supervisort docker container, this will be /data/addons/local/phev_setup

More information about local addons at https://developers.home-assistant.io/docs/add-ons/tutorial/

If you set the debug flag on, it will just start the container and sleep indefinitely.

NOTE - on 32bit Raspberry Pi there's an issue with the latest alpine docker images and old versions of libseccomp (including the ones in Raspbian repos), this will stop the Dockerfile building. In order to overcome this, you may need to manually install a newer version with

    wget http://ftp.us.debian.org/debian/pool/main/libs/libseccomp/libseccomp2_2.4.4-1~bpo10+1_armhf.deb
    dpkg -i libseccomp2_2.4.4-1~bpo10+1_armhf.deb
