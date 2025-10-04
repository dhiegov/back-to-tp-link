#!/bin/sh

echo 'c10b8342b1ea915b40f62f9653a8a76e  wr741nv4_en_3_17_0_up_boot.bin' > firm-orig.md5sum

if md5sum -c firm-orig.md5sum
then
    echo MD5 checksum is ok.
else
    echo Checksum failed, please confirm you have the right firmware file.
    exit 1
fi

echo Creating tplink.bin and orig.bin...
cp wr741nv4_en_3_17_0_up_boot.bin tplink.bin
cp wr741nv4_en_3_17_0_up_boot.bin orig.bin

echo Overwriting tplink.bin skipping some bytes at the beginning with dd...
dd if=orig.bin of=tplink.bin skip=257 bs=512 || exit 1

cat <<EOF

THE FOLLOWING OPERATION MAY BRICK YOUR ROUTER, please double check
the script to be sure it is consistent with the page below,
pay special attention to the commands 'dd' and 'mtd'.

https://openwrt.org/toh/tp-link/tl-wr741nd#back_to_original_firmware

This will only work reliably with the TL-WR741ND, hardware version v4.20,
which is the model we tested against. It may work with the TL-WR741N,
which lacks a Detachable antenna, but we didn't test it.
We do NOT guarantee it works with another variant. You have been warned.

Also keep in mind that if successful, the device will reboot and this
remote session will be terminated as a consequence. After that, going
to http://192.168.0.1 should ask you for login and password.

login: admin
password: admin

Note that https WON'T work, please write out (or copy paste) also the http://

EOF
read -p "If you are sure you want to overwrite the firmware, enter wjrml: " ans

if [ "$ans" = "wjrml" ]
then
    echo Okay, running mtd...
    # reboots the router if successful
    mtd -r write /tmp/tplink.bin firmware
else
    exit 1
fi

cat <<EOF

If you are reading this, it means the overwrite has failed. Do not panic and
do NOT reboot your router, see the following for recovery options, just before
the next section, "Hardware":

https://openwrt.org/toh/tp-link/tl-wr741nd#back_to_original_firmware

EOF
exit 1
