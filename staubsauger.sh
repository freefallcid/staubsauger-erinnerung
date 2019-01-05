#!/bin/bash
date=$(date +%d.%m.%Y);
day=$(date +%-d);
month=$(date +%-m);
to_notification='User email <@>'
to_report='Admin email <@>'
from='Staubsauger-Erinnerung <staubsauger-erinnerung@dominicreich.com>';
subject=`printf "Staubsauger-Erinnerung vom %s" "$date"`;
subject_report=`printf "[Cron Report] $subject"`;
host=$(/bin/hostname);
headers=`printf "From: %s\r\nReply-To: %s\r\nContent-Type: text/html; charset=utf-8\r\n" "$from" "$to_report"`;

# Some default values
send='no'
sendcc='no'
send_report_msg='nicht '

# Change settings here
#sendcc='yes'

if [[ $month == "1" || $month == "3" || $month == "5" || $month == "7" || $month == "9" || $month == "11" ]]; then
    # in diesem Monat senden
    if [ $day -gt "7" ]; then
        # nicht senden, falls wir schon nach der ersten woche sind
        # -> kein 1. Samstag nach 7 Tagen im Monat möglich
        send='no';
        send_report_msg='nicht ';
    else
        # das ist wohl der erste Samstag im oben genannten Monat - los geht's
        send='yes';
        send_report_msg='';
        body='<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="HandheldFriendly" content="True">
  <meta name="MobileOptimized" content="320">
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
</head>
<body>
  <h3>Staubsaugerreinigung vom '`date +%d.%m.%Y`'</h3>
  <div class="main">
    <p>
      Guten Morgen!<br /><br />
      Es ist wieder Zeit, den Staubsauger zu reinigen.<br /
      Falls das schon geschehen ist, kann diese E-Mail ignoriert
      werden.
    </p>
    <p style="margin-top:3.5em;">
      Mit freundlichen Gruessen,<br /><br />
      Ihr freundlicher Erinnerungs-Service
    </p>
  </div>
  <div class="sig">
    <p style="margin-top:1.5em;color:#777;">--&nbsp;<br>Automatisch generierte Email. Bitte nicht darauf antworten.</p>
  </div>
</body>
</html>
<!-- lichtlein ;) -->
';
    fi
else
    # in diesem Monat nicht
    send='no';
    send_report_msg='nicht ';
fi

bodymg='<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="HandheldFriendly" content="True">
  <meta name="MobileOptimized" content="320">
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
</head>
<body>
  <h3>Staubsaugerreinigung vom '`date +%d.%m.%Y`'</h3>
  <div class="main">
    <p style="margin-top:1.5em;">
      Die Erinnerung wurde heute <strong>'"$send_report_msg"'versendet</strong>.
    </p>
  </div>
</body>
</html>
<!-- lichtlein ;) -->
';

if [ $send == "yes" ]; then
    # es wird eine benachrichtigung versendet
    if [ $sendcc == "yes" ]; then
      # auch an den admin/report
      /usr/bin/php -r "mail('$to_notification, $to_report', '$subject', '$body', '$headers');";
    else
      # nur an die notification mail adresse
      /usr/bin/php -r "mail('$to_notification', '$subject', '$body', '$headers');";
    fi
fi

# A report is always sent out. Keeping track if the script works is a good idea.
/usr/bin/php -r "mail('$to_report', '$subject_report', '$bodymg', '$headers');";
