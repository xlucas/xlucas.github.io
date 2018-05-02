---
title: Free github-pages CNAME over SSL
teaser: OVH SSL Gateway serves your github pages on a custom domain over SSL for free.
image: /images/logo.png
comments: true
category: guides
tags: [github, ovh]
---

> #### Update
> Since **May 01 2018**, Github supports serving custom domain over HTTPS, read
> Github [announcement][github announcement] for this feature.

## The limitation
Github pages are a great way to quickly host your personal blog, repository
homepage and any other static content. Combined with [Jekyll][jekyll] you have
enough to host a free, beautiful, highly-configurable website. Github reserves
a subdomain of `github.io` for each user. But what if you want to use a domain
name you own instead? Well, github supports [custom
domains][github-custom-domain]. However, if you try to reach your domain over
https you will find out that the certificate is invalid and the connection is
insecure! That's because *github don't support SSL on custom domains*.

## OVH SSL Gateway
Since a few months, [OVH][ovh-com] proposes amongst its offers a reverse proxy
solution to handle SSL traffic to your infrastructure called [SSL
Gateway][ovh-ssl-gateway-uk]. It provides automatic certificate generation and
configuration from Let's Encrypt, support HSTS, HTTP redirection, IP
restriction and tuning TLS ciphers. It is an interesting alternative to
[Cloudflare][cloudflare] on these aspects, althought the set of surrounding
features is smaller than what the US company offers. There's a free plan that
should be more than sufficient for your custom domain on github pages to
support SSL.

<div class="image-container-shadow">
  <img src="/images/ssl-gateway.png" alt="OVH SSL Gateway"/>
</div>

## Set a CNAME on github
Before anything you should add a `CNAME` file in the root of your github pages
repository with your custom domain name in it. Push your changes. Here's an
[example][github-cname] that is used for this blog.

## Subscribe to the free plan
Visit the [offer's page][ovh-ssl-gateway-uk] and activate your free plan. Enter
the custom domain name and an IP of the [github pages platform][github-ips].
At the time of writing, these are:
```
192.30.252.153
192.30.252.154
```

## Update your DNS configuration
Your current configuration probably looks like this:
```
subdomain IN CNAME <user>.github.io
```
Once your order has been processed you'll receive an email with informations
regarding your service such as the IPv4 and IPv6 addresses of your SSL Gateway.
You now need to make sure your custom domain points to this service and not to
github servers anymore:
```
subdomain IN A    <SSL_Gateway_IPv4>
subdomain IN AAAA <SSL_Gateway_IPv6>
```
For instance with this blog the configuration is:
```
blog IN A    91.134.128.47
blog IN AAAA 2001:41d0:202:100:91:134:128:47
```
In order for the SSL certificate to be issued and verified by Let's Encrypt, a
DNS probe will check for these two records in your zone configuration. Once
found, your gateway will be properly configured and show up in the ['Sunrise'
section][sunrise-ssl-gateway] of the customer interface.


## Redirect the traffic
There's one last thing you need to do, serve *all traffic* in a secure way. For
this to be achieved, go to the configuration page of the gateway, select its
settings and check the following option:

<div class="image-container-shadow">
  <img src="/images/ssl-gateway-options.png" alt="OVH SSL Gateway Options"/>
</div>


Validate to update the gateway's configuration, and you're all set!


[cloudflare]: https://www.cloudflare.com
[github-cname]: https://github.com/xlucas/xlucas.github.io/blob/master/CNAME
[github-custom-domain]: https://help.github.com/articles/using-a-custom-domain-with-github-pages/
[github-ips]: https://help.github.com/articles/setting-up-an-apex-domain/#configuring-a-records-with-your-dns-provider
[jekyll]: https://jekyllrb.com/
[github announcement]: https://blog.github.com/2018-05-01-github-pages-custom-domains-https/
[ovh-com]: https://www.ovh.com
[ovh-ssl-gateway-uk]: https://www.ovh.co.uk/ssl-gateway/
[sunrise-ssl-gateway]: https://www.ovh.com/manager/sunrise/sslGateway/index.html

