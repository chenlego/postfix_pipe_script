#!/bin/bash

# configure postfix master.cf
# remove smtp_to_sonic component from /etc/postfix/master.cf
/bin/sed -i -e '/^smtp_to_sonic unix/d' /etc/postfix/master.cf

/bin/echo "/corp.dozstyle.io/ smtp:mail.dozstyle.io}" | /usr/bin/tee /tmp/transport
/bin/echo "/(localhost|$(hostname))/ local:" | /usr/bin/tee -a /tmp/transport
/bin/cp /tmp/transport /etc/postfix/transport
/usr/sbin/postmap /etc/postfix/transport

# configure postfix main.cf to apply transport setting
/bin/sed -i -e '/^transport_maps = regexp:\/etc\/postfix\/transport/d' /etc/postfix/main.cf
/bin/echo "transport_maps = regexp:/etc/postfix/transport" | /usr/bin/tee -a /etc/postfix/main.cf

# restart postfix
/sbin/service postfix restart
