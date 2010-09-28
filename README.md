# Hoptoad Webhooks

Provide a webhook provider for a hoptoad account.

## Install

Setup a user in Hoptoad which receives emails to a secret account.
This email address should receive all the errors which you want announced.

After this, you will need to setup certain environment variables.

    ENV key                        | Used for                         | Required

    hoptoad_webhooks.imap.host     | IMAP host to connect to          | Yes
    hoptoad_webhooks.imap.port     | Connect to this IMAP port        | No, defaults to 993
    hoptoad_webhooks.imap.username | Connect with this username       | Yes
    hoptoad_webhooks.imap.password | Connect with this password       | Yes
    hoptoad_webhooks.imap.mbox     | Process emails from this mailbox | No, defaults to INBOX
    hoptoad_webhooks.email         | The email address above          | Yes
    hoptoad_webhooks.account_name  | The hoptoad account to process   | Yes
    hoptoad_webhooks.hook_url      | Send hooks to this HTTP URL      | Yes

To use this on heroku, you can setup the configuration as follows:

    heroku config:add config.email=hoptoad-alerts@example.org

Now you can push the code and you'll receive hooks sent to the URL you configured.

You can also view the status of the processor by visiting `http://yourapp.example.org/emails`.
