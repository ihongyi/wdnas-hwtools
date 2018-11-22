#!/bin/bash
#
# WD hardware tools installer for DSM
#

CONFIG=/etc/wdhwd.conf
INSTALLDIR=/usr/local/share/wdhwd
WDHWC=/usr/local/sbin/wdhwc
INITRC=/usr/local/etc/rc.d/wdhwd.sh

# get python pip
curl https://bootstrap.pypa.io/get-pip.py | python

# install required packages
pip install pyserial smbus2

# setup configuration
cp tools/wdhwd.conf ${CONFIG}

# install
cp -dR . ${INSTALLDIR}
chown -R root.root ${INSTALLDIR}
chmod -R u=rwX,go=rX ${INSTALLDIR}
chmod -R u=rwx,go=rx ${INSTALLDIR}/scripts/*

# create wdhw client
cat <<EOF > ${WDHWC}
#!/bin/bash
cd ${INSTALLDIR}
python -m wdhwdaemon.client \$@
EOF
chmod +x ${WDHWC}

# create init rc script
cat <<EOF > ${INITRC}
#!/bin/bash
cd ${INSTALLDIR}
case \$1 in
	start)
		python -m wdhwdaemon.daemon &
		;;
	stop)
		python -m wdhwdaemon.client stop
		;;
	*)
		echo "Usage: wdhwd.sh {start|stop}"
		exit 1
		;;
esac
EOF
chmod +x ${INITRC}
