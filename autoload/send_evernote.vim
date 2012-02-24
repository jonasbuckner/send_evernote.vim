if !exists("g:evernote_gmail_username")
  function! send_evernote#send()
    echo "Must set your GMail username."
  endfunction
  finish
endif

if !exists("g:evernote_email_address")
  function! send_evernote#send()
    echo "Must set your Evernote email address."
  endfunction
  finish
endif


python << EOF
try:
    import gnomekeyring as gkey
except:
    vim.command("let s:no_gnome_keyring = 1")
EOF

if exists("s:no_gnome_keyring")
  function! send_evernote#send()
    echo "No Gnome Keyring module."
  endfunction
  finish
endif


python << EOF
import vim

fromaddr = 'smancill@gmail.com'
toaddr   = vim.eval("g:evernote_email_address")

server   = 'smtp.gmail.com'
protocol = 'smtp'
username = vim.eval("g:evernote_gmail_username")

try:
    attrs = {"server": server, "protocol": protocol}
    password = gkey.find_items_sync(gkey.ITEM_NETWORK_PASSWORD, attrs)[0].secret
except:
    vim.command("let s:no_password_in_keyring = 1")
EOF

if exists("s:no_password_in_keyring")
  function! send_evernote#send()
    echo "Could not get password from keyring"
  endfunction
  finish
endif

python << EOF
import smtplib
import sys

from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

def EvernoteSend():
    subject = vim.current.buffer[0]
    body = '\n'.join(vim.current.buffer[2:])

    if len(subject) == 0 or len(body) == 0:
      print "Empty note"
      return

    msg = MIMEMultipart()
    msg['From'] = fromaddr
    msg['To'] = toaddr
    msg['Subject'] = subject

    text = body.decode('utf-8').encode('latin-1')
    msg.attach(MIMEText(text, 'plain'))

    # The actual mail send
    try:
        gmail = smtplib.SMTP(server + ':587')
        gmail.ehlo()
        gmail.starttls()
        gmail.ehlo()
        gmail.login(username, password)
        gmail.sendmail(fromaddr, toaddr, msg.as_string())
        gmail.quit()
    except:
        print "Could not send mail to Evernote."
    else:
        print "Created new note '%s'." % subject
EOF

function! send_evernote#send()
python << EOF
EvernoteSend()
EOF
endfunction
