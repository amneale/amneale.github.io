---
layout: post
title: "Deploying WordPress with Dokku"
date: 2015-11-23 12:00:00 +0000
categories: wordpress dokku
---
I've briefly mentioned [Dokku](http://progrium.viewdocs.io/dokku/) before. Without going into too much detail, Dokku is a platform (built on [Docker](https://www.docker.com/), and based on [Heroku](https://www.heroku.com/)), that allows users to develop and deploy web applications without the normal infrastructure management associated with doing so. This simplicity is something I'd like for managing my WordPress blog. Deploying a dokku app can be as simple as pushing an application via Git to your server, and apps can be written in a multitude of languages: PHP, Ruby, Python, and NodeJs are just a few popular examples. My host, [DigitalOcean](https://www.digitalocean.com/?refcode=2911d9659912), offer a prebuilt Dokku image on Ubuntu 14.04 so little configuration is necessary on the server side of things.

## How to Deploy WordPress?

The most obvious way of deploying WordPress would be to clone the latest version of WordPress from github, and then push it directly to your server. This will run into issues however for a couple of reasons: Linkingthe correct database will be a hassle, and persisting your wp-content folder with your custom themes and plugins will be impossible. After some extensive Googling, I stumbled across a few docker/dokku implementations, the best of which located at [github.com/romaninsh/docker-wordpress](https://github.com/romaninsh/docker-wordpress). After forking and making a couple of compatibility commits for the latest version of Dokku I have something I can deploy, with the option of using custom .htaccess and wp-config.php files once WordPress has been deployed. You can find my fork at [github.com/amneale/docker-wordpress](https://github.com/amneale/docker-wordpress), or follow the quick instructions below:

### Deploying the app

Assuming a working dokku installation on a server `apps.mysite.com`, to deploy an application called `wordpress`. These commands should be run locally.

<pre>git clone https://github.com/amneale/docker-wordpress.git
cd docker-wordpress
git remote add deploy dokku@apps.mysite.com:wordpress
git push deploy master
</pre>

If everything is successful, you should receive a working URL, e.g. wordpress.apps.mysite.com. Opening that URL will show a database connection error. Let's link up our database next. All commands following should be run on your host operating system (i.e. where dokku is installed).

### Linking the database (using [mariadb plugin](https://github.com/dokku/dokku-mariadb))

<pre>dokku mariadb:create wordpress
dokku mariadb:link wordpress wordpress
</pre>

Now visiting your website should take you through the normal WordPress configuration, after which you have a functioning WordPress blog - congratulations!

### Managing themes & plugins

<pre>cd /var/lib/dokku/volumes/wordpress/app/
ls -l
</pre>

Inside you'll find your wp-content folder which you can customise. Personally I git clone theme/plugin repositories here. Any themes and plugins you upload via zip or install through the WordPress admin interface will also appear here, and persist through re-deployment of your WordPress application.
