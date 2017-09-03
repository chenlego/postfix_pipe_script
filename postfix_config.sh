#!/bin/bash

# configure postfix master.cf
# add content filter script to master.cf
/bin/sed -i -e '/^smtp_to_script unix/d' /etc/postfix/master.cf
/bin/echo 'smtp_to_script unix - n n - - pipe flags=Rq user=nobody argv=/bin/mail_relay.php  ${sender}  ${recipient}' | /usr/bin/tee /tmp/master.cf
/bin/cat /etc/postfix/master.cf | /usr/bin/tee -a /tmp/master.cf
/bin/cp /tmp/master.cf /etc/postfix/master.cf


# configure postfix transport

/bin/echo '/corp.dozstyle.io/ smtp:mail.dozstyle.io' | /usr/bin/tee /tmp/transport
/bin/echo "/(localhost|$(hostname))/ local:" | /usr/bin/tee -a /tmp/transport
/bin/echo "!/(localhost|$(hostname))/ smtp_to_script:dummy" | /usr/bin/tee -a /tmp/transport
/bin/cp /tmp/transport /etc/postfix/transport
/usr/sbin/postmap /etc/postfix/transport

# configure postfix main.cf to apply transport setting
/bin/sed -i -e '/^transport_maps = regexp:\/etc\/postfix\/transport/d' /etc/postfix/main.cf
/bin/echo "transport_maps = regexp:/etc/postfix/transport" | /usr/bin/tee -a /etc/postfix/main.cf

# restart postfix
/sbin/service postfix restart
