# docker-postfix
Simple postfix relay host for your Docker containers. Based on Alpine Linux.

## Description

This image allows you to run POSTFIX internally inside your docker cloud/swarm installation to centralise outgoing email sending. The
embedded postfix enables you to either ____send messages directly_ or _relay them to your company's main server_.

This is a _server side_ POSTFIX image, geared towards emails that need to be sent from your applications. That's why this postfix
configuration does not support username / password login or similar client-side security features.

If you want to set up and manage your POSTFIX installation for end users, this image is not for you. If you need it to manage your
application's outgoing queue, read on.

## TL;DR

To run the container, do the following:
```
docker run --rm --name postfix -p 25:25 vukomir/postfix
```

You can now send emails by using `localhost:25` as your SMTP server address. **Please note that
the image uses the submission (25) port by default**. Port 25 is not exposed on purpose, as it's
regularly blocked by ISP or already occupied by other services.

All standard caveats of configuring the SMTP server apply -- e.g. you'll need to make sure your DNS
entries are updated properly if you don't want your emails marked as spam.

## Configuration options

The following configuration options are available:
```
ENV vars
$MYORIGIN = Postfix myorigin
$RELAYHOST = Host that relays your msgs
$RELAYHOST_USERNAME = An (optional) username for the relay server
$RELAYHOST_PASSWORD = An (optional) login password for the relay server
$MYNETWORKS = allow domains from per Network ( default 127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16 )
```
### `HOSTNAME`

You may configure a specific hostname that the SMTP server will use to identify itself. If you don't do it,
the default Docker host name will be used. A lot of times, this will be just the container id (e.g. `f73792d540a5`)
which may make it difficult to track your emails in the log files. If you care about tracking at all,
I suggest you set this variable, e.g.:
```
docker run --rm --name postfix -e HOSTNAME=postfix-docker -p 25:25 vukomir/postfix
```

### `RELAYHOST`, `RELAYHOST_USERNAME` and `RELAYHOST_PASSWORD`

Postfix will try to deliver emails directly to the target server. If you are behind a firewall, or inside a corporation
you will most likely have a dedicated outgoing mail server. By setting this option, you will instruct postfix to relay
(hence the name) all incoming emails to the target server for actual delivery.

Example:
```
docker run --rm --name postfix -e RELAYHOST=192.168.115.215 -p 25:25 vukomir/postfix
```

You may optionally specifiy a rely port, e.g.:
```
docker run --rm --name postfix -e RELAYHOST=192.168.115.215:25 -p 25:25 vukomir/postfix
```

Or an IPv6 address, e.g.:
```
docker run --rm --name postfix -e 'RELAYHOST=[2001:db8::1]:25' -p 25:25 vukomir/postfix
```

If your end server requires you to authenticate with username/password, add them also:
```
docker run --rm --name postfix -e RELAYHOST=mail.google.com -e RELAYHOST_USERNAME=hello@gmail.com -e RELAYHOST_PASSWORD=world -p 25:25 vukomir/postfix
```

### `MYNETWORKS`

This implementation is meant for private installations -- so that when you configure your services using _docker compose_
you can just plug it in. Precisely because of this reason and the prevent any issues with this postfix being inadvertently
exposed on the internet and then used for sending spam, the *default networks are reserved for private IPv4 IPs only*.

Most likely you won't need to change this. However, if you need to support IPv6 or strenghten the access further, you can
override this setting.

Example:
```
docker run --rm --name postfix -e "MYNETWORKS=10.1.2.0/24" -p 25:25 vukomir/postfix
```
## Extending the image

If you need to add custom configuration to postfix or have it do something outside of the scope of this configuration, simply
add your scripts to `/docker/postfix/init/`. All files will be executed automatically at the end of the
startup script.

Build it with docker and your script will be automatically executed before Postfix starts.
