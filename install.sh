#!/bin/bash

SUDOERS=/etc/sudoers.d/wdhwd
CONFIG=/etc/wdhwd.conf
INSTALLDIR=/usr/local/lib/wdhwd
LOGDIR=/var/log/wdhwd
SERVICE="$(pkg-config systemd --variable=systemdsystemunitdir)/wdhwd.service"

sudo apt install python3 python3-serial python3-smbus hddtemp

sudo useradd -r -U -M -b /var/run -s /usr/sbin/nologin wdhwd
sudo cp tools/wdhwd.sudoers ${SUDOERS}
sudo chown root.root ${SUDOERS}
sudo chmod ug=r,o= ${SUDOERS}

sudo cp tools/wdhwd.conf ${CONFIG}
sudo chown root.root ${CONFIG}
sudo chmod u=rw,go=r ${CONFIG}

sudo cp -dR . ${INSTALLDIR}
sudo chown -R root.root ${INSTALLDIR}
sudo chmod -R u=rwX,go=rX ${INSTALLDIR}
sudo chmod -R u=rwx,go=rx ${INSTALLDIR}/scripts/*

sudo mkdir ${LOGDIR}
sudo chown root.wdhwd ${LOGDIR}
sudo chmod -R ug=rwX,o= ${LOGDIR}

sudo cp tools/wdhwd.service.no_root $SERVICE
sudo chown root.root $SERVICE
sudo chmod u=rw,go=r $SERVICE
sudo systemctl enable wdhwd.service
sudo systemctl start wdhwd.service

