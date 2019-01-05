#!/bin/sh
# Erinnerung versenden, damit man den Staubsauger im Keller
# nicht vergisst zu reinigen.
# Intervall bis jetzt: alle 2 Monate
# 
# Last modified: Samstag, 05.01.2019 10:48
#
#
# *** CHANGELOG
# 
# Grosses Update am 14. Juni 2015:
#   Laeuft jetzt auf FreeBSD
#   Minimale Aenderungen zur Verwendung von sendmail (Header im $BODY)
# Update am 25. Oktober 2015
#   Syntax wurde von ZSH zu SH portiert
# Update am 3. Juli 2016
#   Script wurde auf Webspace von Hetzner geladen und angepasst.
#   Fehler sind im Cronjob enthalten, diese muessen noch beseitigt
#   werden.
#   Die Datumsverifizierung erfolgt nur noch im Crontab. Das Script
#   wird einfach durchlaufen, ohne Datumscheck.
#   Mehr Debug-Information hinzugefuegt.
# Update am 24. Juli 2016
#   Einige Veränderungen am BODY der Email sowie das weglassen
#   der Cron-Standardnachricht (versnendet an den Benutzer 'klamma')
#   Datumsverifizierung wurde wieder ins Script gepackt, da ständig
#   Fehlermeldungen kamen.
#   Management-Emails (cron-report) werden als HTML Mails versendet (bessere
#   Darstellung auf kleinen Displays (Handy))
# Update am 11. September 2016
#   Kommentar hinzugefügt (explains sending or not sending status
#   reports)
# Update am 21. Jänner 2017
#   Fehler beseitigt (sending or not sending status reports etc)
#   Irgendwo im if-Statement war ein Fehler
# Update am 5. März 2017
#   Migration von hetzner webspace zu hetzner rootserver
#   (gefion.dominicreich.com) - FreeBSD
# Update am 25. März 2017
#   Fehler behoben, bei dem der Report ständig gesendet wurde (an
#   jedem Samstag).
#   Außerdem stehen jetzt die Quellcodes der beiden Emails nur
#   einmal im Sourcecode des Skriptes.
# Update am 2. November 2018
#   Report wird immer gesendet (sofern der cronjob ausgeführt wird)
#	

HEUTE="`date +%_d`"
FROM='Staubsauger-Erinnerung <@>'
BETREFF='Staubsauger-Reinigung vom '`date +%d.%m.%Y`
TO='User 1 <@>'
CC='User 2 <@>'

# SENDCC: Send a copy to myself ($CC) - or only the report.
SENDCC="NO"
# for security not to make mistakes, set this to NO so if something
# breaks, its still on NO
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


#    <p>Der fuer dieses Script verantwortliche Cronjob lautet:</p>
#    <div class="cron"><code><pre>'$(crontab -l | grep vacuum-cleaner)'</pre></code></div>

#<p>Nachfolgend der Inhalt des Scripts:</p>
#
#<div class="script"><code><pre>'`awk '{print "> " $0}' $0`'</pre></code></div>
#'
#</body>
#</html>
#'

# last active:
#echo "$BODY" | mutt -e "unset record" -e "my_hdr From: $FROM" -e "set content_type=text/html" -c "$CC" -s "$BETREFF" -- "$TO"

# for reference
#echo "$BODY" | mutt -e "unset record" -e "my_hdr From: $FROM" -c "$CC" -s "$BETREFF" -- "$TO"
# mutt -e "unset record" -e "set content_type=text/html" Email address -s "subject" < test.html

# very old method
#echo -e "$BODY" | /usr/sbin/sendmail -t

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
  #echo "$BODYMG" | mutt -e "unset record" -e "my_hdr From: $FROM" -e "set content_type=text/html" -s "[Cron Report] $BETREFF" -- "$TO"

else

  echo "Ein Fehler im Script is aufgetreten. (Weder 'YES' noch 'NO' - $0)"

fi

return 0

