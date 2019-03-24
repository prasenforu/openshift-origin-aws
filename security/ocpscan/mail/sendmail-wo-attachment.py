#!/usr/bin/env python

# Python script to send email with attachment
# using your gmail account/credentials

# usage: if you are saving your script as: send-email.py:
# ./send-email.py "subject-here" "Receiver MAil ID" "path of file to be attached"

import smtplib
import sys
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

filename = "./mailbody.txt"

# Configuration: replace all parts in <brackets> with your actual information

user = 'username@gmail.com'
password  = 'password'
sender   = 'username@gmail.com'

# Create message container - the correct MIME type is multipart/alternative.
recipient = str(sys.argv[2])
msg = MIMEMultipart('alternative')
msg['Subject'] = str(sys.argv[1])
msg['From'] = sender
msg['To'] = recipient   # needs to be a list

# Read a file (mailbody.txt)
fo = open(filename)
filecontent = fo.read()

# Record the MIME types of both parts - text/plain and text/html.
part1 = MIMEText(filecontent)

# Attach parts into message container.
msg.attach(part1)

### For Attachment ###
part = MIMEApplication(open(str(sys.argv[3]),"rb").read())
part.add_header('Content-Disposition', 'attachment', filename=str(sys.argv[3]))
msg.attach(part)
######################

server = smtplib.SMTP("smtp.gmail.com:587")
server.set_debuglevel(0)
server.ehlo()
server.starttls()
server.ehlo()
server.esmtp_features['auth'] = 'LOGIN PLAIN'
server.login(user, password)
server.sendmail(sender, recipient, msg.as_string())
server.close()
