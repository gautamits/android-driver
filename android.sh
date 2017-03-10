read -p "disconnect your android and enter y " answer
lsusb > ~/.with-android
read -p "connect your and enter y " answer
lsusb > ~/.without-android
vendor_id=$( diff ~/.with-android ~/.without-android | grep ":" | cut -f7 -d " " | cut -f1 -d":" )
product_id=$( diff ~/.with-android ~/.without-android | grep ":" | cut -f7 -d " " | cut -f2 -d":" )
echo "vendor id is ${vendor_id}"
echo "product id is ${product_id}"
if [ -f /etc/udev/rules.d/51-android.rules ] ; then 
	if grep -q ${product_id} /etc/udev/rules.d/51-android.rules ; then
		echo "adb and fastboot driver for this device is already installed"
	else
		echo  "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"${vendor_id}\", MODE=\"0660\", GROUP=\"adbusers\"" >> /etc/udev/rules.d/51-android.rules
        	echo  "SUBSYSTEM==\"usb\",ATTR{idVendor}==\"${vendor_id}\",ATTR{idProduct}==\"${product_id}\",SYMLINK+=\"android_adb\"" >> /etc/udev/rules.d/51-android.rules
        	echo  "SUBSYSTEM==\"usb\",ATTR{idVendor}==\"${vendor_id}\",ATTR{idProduct}==\"${product_id}]\",SYMLINK+=\"android_fastboot\"" >> /etc/udev/rules.d/51-android.r$
	fi
else
	echo  "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"${vendor_id}\", MODE=\"0660\", GROUP=\"adbusers\"" >> /etc/udev/rules.d/51-android.rules
	echo  "SUBSYSTEM==\"usb\",ATTR{idVendor}==\"${vendor_id}\",ATTR{idProduct}==\"${product_id}\",SYMLINK+=\"android_adb\"" >> /etc/udev/rules.d/51-android.rules
	echo  "SUBSYSTEM==\"usb\",ATTR{idVendor}==\"${vendor_id}\",ATTR{idProduct}==\"${product_id}]\",SYMLINK+=\"android_fastboot\"" >> /etc/udev/rules.d/51-android.rules

fi
echo "adding mtp rules"
if [ -f /lib/udev/rules.d/69-mtp.rules ] ; then 
        if grep -q ${product_id} /lib/udev/rules.d/69-mtp.rules ; then
                echo "mtp driver for this device is already installed"
        else
                echo "ATTR{idVendor}==\"${vendor_id}\", ATTR{idProduct}==\"${product_id}\", SYMLINK+=\"libmtp-%k\", ENV{ID_MTP_DEVICE}=\"1\", ENV{ID_MEDIA_PLAYER}=\"1\"" >> /lib/udev/rules.d/69-mtp.rules
        fi
else
       echo "ATTR{idVendor}==\"${vendor_id}\", ATTR{idProduct}==\"${product_id}\", SYMLINK+=\"libmtp-%k\", ENV{ID_MTP_DEVICE}=\"1\", ENV{ID_MEDIA_PLAYER}=\"1\"" >> /lib/udev/rules.d/69-mtp.rules


fi
apt-get install libmtp-common mtp-tools libmtp-dev libmtp-runtime libmtp9 android-tools-adb android-tools-fastboot
service udev restart
rm ~/.with-android
rm ~/.without-android
