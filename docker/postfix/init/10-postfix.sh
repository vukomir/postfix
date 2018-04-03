#!/usr/bin/env bash

# Set up host name
if [ ! -z "$HOSTNAME" ]; then
	postconf -e myhostname="$HOSTNAME"
else
	postconf -# myhostname
fi

# Set up my origin
if [ ! -z "$MYORIGIN" ]; then
	postconf -e myorigin="$MYORIGIN"
else
	postconf -e myorigin="$HOSTNAME"
fi

# Set up a relay host, if needed
if [ ! -z "$RELAYHOST" ]; then
	echo -n "- Forwarding all emails to $RELAYHOST"
	postconf -e relayhost=$RELAYHOST

	if [ -n "$RELAYHOST_USERNAME" ] && [ -n "$RELAYHOST_PASSWORD" ]; then
		echo " using username $RELAYHOST_USERNAME."
		echo "$RELAYHOST $RELAYHOST_USERNAME:$RELAYHOST_PASSWORD" >> /etc/postfix/sasl_passwd
		postmap hash:/etc/postfix/sasl_passwd
		postconf -e "smtp_sasl_auth_enable=yes"
		postconf -e "smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd"
		postconf -e "smtp_sasl_security_options=noanonymous"
	else
		echo " without any authentication. Make sure your server is configured to accept emails coming from this IP."
	fi
else
	echo "- Will try to deliver emails directly to the final server. Make sure your DNS is setup properly!"
	postconf -# relayhost
	postconf -# smtp_sasl_auth_enable
	postconf -# smtp_sasl_password_maps
	postconf -# smtp_sasl_security_options
fi

# Set up my networks to list only networks in the local loopback range

if [ ! -z "$MYNETWORKS" ]; then
	postconf -e mynetworks=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,$MYNETWORKS
else
	postconf -e "mynetworks=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12"
fi


#rewrite email destinations

if [ -f /etc/postfix/rewrite ]; then

	postconf /etc/postfix/rewrite
        postconf -e "recipient_canonical_maps = regexp:/etc/postfix/rewrite"
fi
