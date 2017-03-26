#!/usr/bin/python
import subprocess
from easygui import *
import os
euid = os.geteuid() 
if euid != 0:
  raise EnvironmentError, "need to be root"
  exit()
proc = subprocess.Popen(["lsusb"], stdout=subprocess.PIPE, shell=False)
(out, err) = proc.communicate()
out=out.rstrip("\n")
out=out.split("\n")
devices=multchoicebox(msg='Select all android devices.', title='Select Android Devices', choices=(out))
if devices is None:
	exit(0)
for i in range(len(devices)):
	j=str(devices[i])
	#print "Installing Driver for ",j
	j=j.split(':')
	vendor_id=j[1].split(" ")[2]
	product_id=j[2].split(" ")[0]
	device_name=" ".join(j[2].split(" ")[1:])
	#print device_name,vendor_id,product_id
	#print "adding to adb rules"
	if os.path.exists("/etc/udev/rules.d/51-android.rules"):
		print "file exists"
	else:
		print "file does not exists"
		try:
			print "creating new file"
			open("/etc/udev/rules.d/51-android.rules","w+")
		except:
			print "not permitted to create file"
	try:
		f=open('/etc/udev/rules.d/51-android.rules', 'r+')
		installed=False
		for line in f:
			line=line.rstrip('\n')
			if vendor_id in line and product_id in line:
				print "driver already installed"
				installed=True
				f.close()
				break
		if installed==False:

			print "installng"
			f.write("#"+device_name+"\n")
			f.write('SUBSYSTEM=="usb",ATTR{idVendor}=="'+vendor_id+'", ATTR{idProduct}=="'+product_id+'", MODE="0666", OWNER="amit"\n')
			f.write('SUBSYSTEM=="usb",ATTR{idVendor}=="'+vendor_id+'", MODE="0660", GROUP="adbusers"\n')
			f.write('SUBSYSTEM=="usb",ATTR{idVendor}=="'+vendor_id+'",ATTR{idProduct}=="'+product_id+'",SYMLINK+="android_adb"\n')
			f.write('SUBSYSTEM=="usb",ATTR{idVendor}=="'+vendor_id+'",ATTR{idProduct}=="'+product_id+'",SYMLINK+="android_fastboot"\n')
			print "successfully writeen"
			f.close()
	except:
		print "cannot open file"
