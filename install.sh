#!/bin/bash
#
# WD hardware tools installer for Debian Stretch
#

apt install pkg-config

SUDOERS=/etc/sudoers.d/wdhwd
CONFIG=/etc/wdhwd.conf
INSTALLDIR=/usr/local/lib/wdhwd
LOGDIR=/var/log/wdhwd
SERVICE="$(pkg-config systemd --variable=systemdsystemunitdir)/wdhwd.service"

# ensure the 8250_lpss driver is loaded
lspci -k -s 00:1e | grep 8250_lpss
if [[ ! $? ]]; then
	echo "8250_lpss driver is missing"
	exit 1
fi

# now install wdhw tools
apt install python3 python3-serial python3-smbus hddtemp

# create wdhwd user
useradd -r -U -M -b /var/run -s /usr/sbin/nologin wdhwd
usermod -a -G dialout wdhwd

cp tools/wdhwd.sudoers ${SUDOERS}
chown root.root ${SUDOERS}
chmod ug=r,o= ${SUDOERS}

cp tools/wdhwd.conf ${CONFIG}
chown root.root ${CONFIG}
chmod u=rw,go=r ${CONFIG}

cp -dR . ${INSTALLDIR}
chown -R root.root ${INSTALLDIR}
chmod -R u=rwX,go=rX ${INSTALLDIR}
chmod -R u=rwx,go=rx ${INSTALLDIR}/scripts/*

mkdir ${LOGDIR}
chown root.wdhwd ${LOGDIR}
chmod -R ug=rwX,o=rX ${LOGDIR}

cp tools/wdhwd.service.no_root $SERVICE
chown root.root $SERVICE
chmod u=rw,go=r $SERVICE
systemctl enable wdhwd.service
systemctl start wdhwd.service

