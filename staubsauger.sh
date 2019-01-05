#!/bin/sh
# Erinnerung versenden, damit man den Staubsauger im Keller
# nicht vergisst zu reinigen.
# Intervall bis jetzt: alle 2 Monate
# 
# Last modified: Samstag, 05.01.2019 10:48
#

HEUTE="`date +%_d`"
FROM='Staubsauger-Erinnerung <@>'
BETREFF='Staubsauger-Reinigung vom '`date +%d.%m.%Y`
TO='User 1 <@>'
CC='User 2 <@>'

# SENDCC: Send a copy to myself ($CC) - or only the report.
SENDCC="NO"
SENDREPORT='NO'

if [ $HEUTE -gt "7" ]; then
  # nicht versenden
  SENDREPORT='NO'
  SENDREPORTMSG='nicht '
  #return 0
else
  # versenden
  SENDREPORT='YES'
  SENDREPORTMSG=''
  BODY='<html>
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
'
fi

BODYMG='<html>
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
    <p>Die Erinnerung wurde heute ('$(date +%d.%m.%Y)') <strong>'"$SENDREPORTMSG"'versendet</strong>.</p>
  </div>
  <hr size="1" width="100%" align="left">
  <div class="sig">
    <p>Aktueller Crontab Eintrag:</p>
        <div class="cron"><code><pre>'$(crontab -l|egrep "(^[^#][0-9])(.*staubsauger.*)\>")'</pre></code></div>
  </div>
  <p>Falls du keinen Crontab Eintrag siehst, wurde das Skript manuell ausgeführt.</p>
</body>
</html>
<!-- lichtlein ;) -->
'

if [ "$SENDCC" = "YES" ]; then
  if [ "$SENDREPORT" = "YES" ]; then
    echo "$BODY" | mutt -e "unset record" -e "my_hdr From: $FROM" -e "set content_type=text/html" -e "my_hdr X-Priority: 1" -c "$CC" -s "[Erinnerung] $BETREFF" -- "$TO"
  fi
  echo "$BODYMG" | mutt -e "unset record" -e "my_hdr From: $FROM" -e "set content_type=text/html" -s "[Cron Report] $BETREFF" -- "$CC"
elif [ "$SENDCC" = "NO" ]; then
  if [ "$SENDREPORT" = "YES" ]; then
    echo "$BODY" | mutt -e "unset record" -e "my_hdr From: $FROM" -e "set content_type=text/html" -e "my_hdr X-Priority: 1" -s "[Erinnerung] $BETREFF" -- "$TO"
  fi
  echo "$BODYMG" | mutt -e "unset record" -e "my_hdr From: $FROM" -e "set content_type=text/html" -s "[Cron Report] $BETREFF" -- "$CC"
else
  echo "Ein Fehler im Script is aufgetreten. (Weder 'YES' noch 'NO' - $0)"
fi

return 0

