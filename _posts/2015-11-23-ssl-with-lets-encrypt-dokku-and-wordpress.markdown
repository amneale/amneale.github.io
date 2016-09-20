---
layout: post
title: "SSL with Let’s Encrypt, Dokku, and WordPress"
date: 2015-11-25 12:00:00 +0000
categories: wordpress dokku
---
These days more and more web traffic is switching to HTTPS. What was once used only for 'secure' websites where a user would input sensitive data has become more widespread. As well as protecting user data from man-in-the-middle attacks, it has started gaining recognition and therefore trust from users as online security information grows. Crucially, Google use it as a [ranking signal](http://googlewebmastercentral.blogspot.co.uk/2014/08/https-as-ranking-signal.html), and as a result we see a lot more website switching to HTTPS by default. Historically switching to HTTPS has historically been a costly process - in time, money, and sanity - but as demand has grown, so too have free solutions.

## Let's Encrypt

[Let's Encrypt](https://letsencrypt.org/) is a certificate authority (CA) offering a free and automated process, allowing users to generate SSL certificates without jumping through lots of hoops. As of December 3rd, 2015 they'll be entering public beta so anyone owning a domain is free to head over and grab a certificate. The dream behind Let's Encrypt is that any server administrator can download the `letsencrypt` tool, and then both generate certificates and configure their web-server simply by running `letsencrypt run`, and then renew it 90 days (their certificate lifetime) later by running `letsencrypt renew --cert-path example-cert.pem`

## Let's Encrypt & Dokku

<div class="well">**Dokku now have an official letsencrypt plugin [https://github.com/dokku/dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt) which will handle certificate generation, linking and renewal for you.**</div>

### Generating certificates

Unfortunately Let's Encrypt does not work out of the box with dokku, and their nginx plugin is currently in beta, however we can still use it _relatively_ simply.

<pre>sudo service nginx stop</pre>

Firstly, you will need to manually stop nginx as letsencrypt needs port 80/443 open while generating a certificate.

<pre>docker run -it --rm -p 443:443 -p 80:80 --name letsencrypt \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
    quay.io/letsencrypt/letsencrypt:latest \
    --agree-dev-preview --server https://acme-v01.api.letsencrypt.org/directory \
    -d www.example.com auth
</pre>

Ok, that's quite the command, let's run through what it's doing:

*   We're telling docker we want to `run` a command in a new container. The `-it` flags mean we run it interactively, `--rm` means we want to remove the container once the command is run, `-p` specifies publishing the container to ports 80 and 443, and `--name` names the container 'letsencrypt'.
*   `-v` binds volumes inside the container to directories outside the container on the server, allowing our letsencrypt container to access letsencrypt data elsewhere the server.
*   `quay.io/letsencrypt/letsencrypt:latest` is the image we want to use to build the container, in this case the lastest version of letsencrypt.
*   Everything else makes up the command we're running on the letsencrypt container, we want to automatically `--agree-dev-preview`, use the letsencrypt `--server` to generate our certificate, our `-d` domain is (for these purposes) www.example.com, and we want to `auth` (i.e. authenticate only, and not let letsencrypt try to configure the webserver automatically).

Once that has executed, let's not forget to start nginx again.

<pre>sudo service nginx start</pre>

### Linking certificates to a container

Once run, letsencrypt should generate our keys/certs and tell us where they've been stored. Now to add them to a Dokku container we'll be using the dokku certs plugin, which has come bundled since 0.4.0. We first need to copy the keys into a .tar file in a format dokku will be able to process, and then tell the container (in this case `example_com`) to use them.

<pre>cp /etc/letsencrypt/live/www.example.com/privkey.pem server.key
cp /etc/letsencrypt/live/www.example.com/fullchain.pem server.crt
tar cvf cert-key.tar server.crt server.key
dokku certs:add example_com < cert-key.tar
</pre>

Dokku should automatically amend the nginx config for the given container, and reload it - meaning your site will now be using HTTPS, and - by default - routing HTTP traffic to HTTPS.

## SSL, nginx & WordPress

After setting my blog up I ran into a gotcha instantly. While running on HTTPS and showing a secure icon in the address bar, my blog was still attempting to serve all of my CSS and JavaScript from HTTP, and the results were not pretty. After some research I found that WordPress is actually designed to detect HTTPS traffic and serve content accordingly, however my server setup of using nginx as a reverse proxy for apache meant that the native [`is_ssl()`](https://codex.wordpress.org/Function_Reference/is_ssl) function was returning false. While this will hopefully be fixed in future releases, for now the fix (hack?) is to set the server HTTPS variable manually, when detecting HTTPS forwarded traffic. This snippet of code can be placed within wp-config.php, just above the require_once call.:

<pre>if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    $_SERVER['HTTPS'] = 'on';
}
</pre>