#!/usr/bin/php -d open_basedir=
<?php
  # If the message cannot be captured to file, mail delivery is deferred by terminating with exit status 75 (EX_TEMPFAIL). Postfix places the message in the deferred mail queue and tries again later.
  const EX_TEMPFAIL=75;
  # If the content filter program finds a problem, the mail is bounced by terminating with exit status 69 (EX_UNAVAILABLE). Postfix will send the message back to the sender as undeliverable mail.
  const EX_UNAVAILABLE=69;
  # If filter result is OK, the mail is return exit status 0 .
  const EX_OK=0;

#############################################################
### Main
#############################################################
try {
  ## enable log
  $log = '/var/log/mail_relay.log';
  # get mail content and header from postfix
  $rawmsg = file_get_contents('php://stdin');
  $metadata = $argv;
  # $argv[0] is program name
  # $argv[1] is sender
  # $argv others are recipients and cooresponding name
  $prog = array_shift($metadata);
  $sender = array_shift($metadata);
  $recipients = array();

  if ( ! count($metadata) >= 1 )
  {
    throw new Exception("there is no any recipient");
  }

  # currently, you already get sender, recipients and email content
  # then you can do what you want to do
  # for example: calling your email api to send email

  # remember to exit with 0, let postfix know you well done to send the email
  exit(EX_OK);
}
catch (Exception $e) {
  #exit(EX_TEMPFAIL);
  # when you suffered any unexpected errors, you can put the email to postfix defferred queue with return code "EX_TEMPFAIL"
  print("cannot sent", $log);
  exit(EX_TEMPFAIL);
}
