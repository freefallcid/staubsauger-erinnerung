# This script is now ron from Synology webinterface on my DiskStation
# I'll port this one back into a shell script again - this one currently does not work properly
# so I need more testing but don't have that time yet. I want to save this down somewhere in case
# that I need to recover this. (it does not produce any errors on my DiskStation for now, but it also
# does not send any mails out, no logs, nothing...)

date=$(date +%d.%m.%Y);
day=$(date +%-d);
month=$(date +%-m);
source /etc/synoinfo.conf;
from='Staubsauger-Erinnerung <staubsauger-erinnerung@dominicreich.com>';
subject=`printf "Staubsauger-Erinnerung vom %s" "$date"`;
host=$(/bin/hostname);
headers=`printf "From: $from\r\n"`;

if [ ${#eventmail2} -gt 0 ]; then
    to=`printf "%s, %s" "$eventmail1" "$eventmail2"`;
else
    to=$eventmail1;
fi

to_report=$eventmail1;
subject_report=`printf "\[Cron Report\] $subject"`;

send='no';
send_report_msg='nicht ';

echo "debug: now we select month";

if [ $month == "1" || $month == "3" || $month == "5" || $month == "7" || $month == "9" || $month == "11" ]; then
    # in diesem Monat senden
    echo "debug: month selected... : $month";
    if [ $day -gt "7" ]; then
        echo "debug: day selected... : $day - from: $date";
        # nicht senden, falls wir schon nach der ersten woche sind
        # -> kein 1. Samstag nach 7 Tagen im Monat möglich
        send='no';
        send_report_msg='nicht ';
    else
        echo "debug: day over 7... : $day - from: $date";
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
  <hr size="1" width="100%" align="left">
  <div class="main">
    <p>Guten Morgen!<br /><br />
    Es ist wieder Zeit, den Staubsauger zu reinigen.
    Falls das schon geschehen ist, kann diese E-Mail ignoriert
    werden.</p>
    <p>Mit freundlichen Gruessen,<br /><br />
    <em>Ihr freundlicher Erinnerungs-Service</em> ;-)</p>
  </div>
  <hr size="1" width="100%" align="left">
  <div class="sig">
    <p style="margin-top:2.5em;color:#777;">--&nbsp;<br>Automatisch generierte Email.</p>
  </div>
</body>
</html>
<!-- lichtlein ;) -->
';
    fi
else
    echo "debug: not in this month... - $month";
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
    <p>Die Erinnerung wurde heute <strong>'"$send_report_msg"'versendet</strong>.</p>
  </div>
  <!-- <hr size="1" width="100%" align="left"> -->
</body>
</html>
<!-- lichtlein ;) -->
';

#/usr/bin/php -r "mail('$to', '$subject', '$body', '$headers');";

if [ $send == "yes" ]; then
    # es wird eine benachrichtigung versendet
    /usr/bin/php -r "mail('$to', '$subject', '$body', '$headers');";
fi

/usr/bin/php -r "mail('$to_report', '$subject_report', '$bodymg', '$headers');";

echo "Script finished.";
