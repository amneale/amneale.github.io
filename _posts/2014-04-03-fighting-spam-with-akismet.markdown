---
layout: post
title: "Fighting spam with Akismet"
date: 2014-04-03 12:00:00 +0000
categories: wordpress akismet
---
Over the last few weeks it appears some nefarious individuals have located my website and added me to their database of people to inundate with emails about suspicious sounding pills. Now that my medicine cabinet is fully stocked, I decided it was time to put a stop to further spam clogging up my inbox. Wordpress comes packaged with the Akismet plugin which is set up to check comment submissions, however I want it to also check any messages sent via my own contact form, so a little more digging is required.

## Register with Akismet

Firstly, to get any functionality from the Akismet plugin you will need an API key. You can get this over at [https://akismet.com/plans/](https://akismet.com/plans/), there are a variety of plans but for a personal (non-commercial) blog you can essentially choose what you pay for the pleasure of using the service. If you have an existing Wordpress.com account you can simply link Akismet to it, simple! Once this has been done you should receive an email with your API key, failing this you should be able to view it in the akismet.com dashboard.

### Setting up the Akismet plugin

Now that you've got your key, you'll need to make sure the Akismet plugin is enabled in your list of plugins. If it is you will be able to navigate through to the settings page and enter your key. By now you should see some default settings along with server connectivity reporting. Once this is all set up we're good to crack on with the code itself.

### Catching the spam

Before whatever point you are emailing the contact form data you can now send this data to Akismet and make sure it is [ham](https://wiki.apache.org/spamassassin/Ham) as opposed to spam. The first step to take is to ensure your key is valid, and the Akismet service is responding, this is simply done using the function `akismet_verify_key()` found in the Akismet plugin:

<pre>if(function_exists('akismet_get_key') && akismet_verify_key(akismet_get_key()) == 'valid') {
    // check for spam
}</pre>

If this returns true we can continue to set up our contact form data, and use it to build a query string that we'll send to Aksimet, replacing the 3 last variables with whatever you pick up from the posted contact form:

<pre>$data = array(
    'blog' => get_option('home'),
    'user_ip' => $_SERVER['REMOTE_ADDR'],
    'user_agent' => isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : null,
    'referrer' => isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : null,
    'comment_type' => 'contact-form',
    'comment_author' => $contact_form_author, // the name of the user attempting to send the message
    'comment_author_email' => $contact_form_author_email, // the email address of the user attempting to send the message
    'comment_content' => $contact_form_message // the message that is being sent
);

$request = http_build_query($data);</pre>

You can find a list of all available parameters in the [API Documentation](https://akismet.com/development/api/#comment-check). Now our query string is built, we can use the function `akismet_http_post(...)` within the Aksimet plugin to send our data and get a response as to whether spam was detected!

<pre>$host = akismet_get_key() . '.rest.akismet.com';
$path = '/1.1/comment-check';

$response = akismet_http_post($request, $host, $path);
$spam_caught = $response[1]=='true';</pre>

Now if we receive a positive we know that we have caught a spammer in the act and can happily disregard the message. You are able to see statistics within the Wordpress Dashboard about how much spam and ham your blog is receiving. Happy spam hunting!
