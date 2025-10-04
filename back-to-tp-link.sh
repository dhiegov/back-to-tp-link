#!/bin/sh

cat <<EOF

This script is meant specifically for the TL-WR741ND model,
hardware version v4.20.  It may work with the TL-WR741N,
which lacks a Detachable antenna, but we didn't test it.

We do NOT guarantee that it is going to work for any
version different than the specified above.

Please confirm you checked the version and read
this by typing rxwzr below.

We initially assume you have internet connection, so we can
download the firmware for you. There's no need for that
if we can find the zip in the same directory as this script.
EOF

sep="===================================================================="
ans=""
read -p "$PS2" ans

if [ "$ans" = "rxwzr" ]
then
    echo "Thank you."
else
    echo "Please read the output above and try again."
    exit 1
fi

trunc_name="TL-WR741ND_V4.20_140410"
firm="wr741nv4_en_3_17_0_up_boot"
firm_paren="${firm}(140410)"
firm_url='https://static.tp-link.com/resources/software/TL-WR741ND_V4.20_140410.zip'

if [ ! -f "${trunc_name}.zip" ]
then
    echo $sep
    echo "zip file not found in working directory,"
    echo "press enter do download it or Ctrl-c to abort."
    read null
    wget $firm_url
fi

unzip -qn "${trunc_name}.zip" "${trunc_name}/${firm_paren}.bin" || exit 1
cp "${trunc_name}/${firm_paren}.bin" "${firm}.bin"

echo $sep
cat <<EOF

Now connect to the router by one of its LAN ports.
Through telnet, change the root password:

$ telnet 192.168.1.1
# passwd
# exit

It will prompt you for a new one, please keep it somewhere
as we'll need it when transferring files with scp.
While prompting you for a confirmation, it may say your
password is bad, but it is still going to change it,
you can ignore this message.

If you get 'Connection refused' or 'Login failed.',
then the password was already changed and you'll
need to reset the router if you don't remember it.
Behind it there's a hole labeled RESET and a
button inside, press and hold it for 10 seconds.
All of its LEDs will turn on for a moment, wait
a bit until it reboots then try telnet again.

Type tgsot if you did the steps above or Ctrl-c to
do them yourself, run this script again when ready.
EOF

read -p "$PS2" ans
if [ $ans = "tgsot" ]
then
    echo "Thank you."
else
    echo "Please read the output above and try again."
    exit 1
fi

# We tried searching for "192.168.1.1", but in some cases
# ssh doesn't store the public key with the IP, using
# instead a long seeminly random string as identification.
# We also found out that even with this string as ID,
# specifying the IP to ssh-keygen works fine.
if grep -qs "ssh-rsa" ~/.ssh/known_hosts
then
    echo $sep
    cat <<EOF

If you did this same procedure from this machine to
a previous router Alice, ssh/scp has associated this same
IP address (192.168.1.1) to Alice's public key.

When we try to login to the current router Bob, at
the same IP, ssh will warn you Bob presents a different
public key and conclude it's a man-in-the-middle trying
to pretend it's Alice, but it's not: you intentionally
swapped the router.

The following operation will remove the link between
Alice's key and 192.168.1.1, avoiding the warning.

Preemptively remove existing public key associated
with 192.168.1.1? [y/N]:
EOF
    read -p "$PS2" ans
    if [ "$ans" = "y" ]
    then
        ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "192.168.1.1"
        if [ "$?" -ne 0 ]
        then
            echo We failed to do it for you. In this case,
            echo just follow the instructions given by ssh.
        fi
    fi
fi

echo Sending firmware and our revert script to the router with scp...
scp "${firm}.bin" runs-on-the-router.sh root@192.168.1.1:/tmp || exit 1

echo $sep
cat <<EOF

Okay, so now it's time to ssh into the router,
go to /tmp, make our script executable and run it,
which are the commands below

# cd /tmp
# chmod u+x runs_on_the_router.sh
# ./runs_on_the_router.sh

We'll start the session for you.

EOF

ssh root@192.168.1.1
exit 0
