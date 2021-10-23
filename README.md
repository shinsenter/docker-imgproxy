# Ultra Image Server

![www/noimage_thumb.jpg](www/noimage_thumb.jpg)

🌐 A production grade on-the-fly image processing server setup using [imgproxy](https://imgproxy.net) and [Nginx caching](https://www.Nginx.com/products/Nginx/caching/).

## Table of contents
- [Why it's good](#why-its-good)
- [Getting started](#getting-started)
- [Examples](#examples)
- [Debugging](#debugging)
- [Configurations](#configurations)

---

![docker-imgproxy](www/project.jpg)

- **Author**: Mai Nhut Tan <shin@shin.company>
- **Copyright**: 2021 AppSeeds <https://code.shin.company/docker-imgproxy#readme>


## Support my activities

If you like this repository, please hit the star button to follow further updates, or buy me a coffee 😉.

[![Donate via PayPal](https://img.shields.io/badge/Donate-Paypal-blue)](https://www.paypal.me/shinsenter) [![Become a sponsor](https://img.shields.io/badge/Donate-Patreon-orange)](https://www.patreon.com/appseeds) [![Become a stargazer](https://img.shields.io/badge/Support-Stargazer-yellow)](https://github.com/shinsenter/docker-imgproxy/stargazers) [![Report an issue](https://img.shields.io/badge/Support-Issues-green)](https://github.com/shinsenter/docker-imgproxy/discussions/new)

I really appreciate your love and supports.


---


## Why it's good

- Just download this project and run <sup>`(*)`</sup>.
- Fast on-the-fly generating thumbnails thanks to `imgproxy`.
- High availability and performance thanks to Nginx content caching.
- Forget troubles of [Image URL signature](https://docs.imgproxy.net/configuration?id=url-signature), but still ensure the security of the service.
- Easily serve local files as well as from other origin servers.
- Flexible in customizing SEO-friendly URLs without exposing `imgproxy` options (which are long and hard to remember).
- Flexible in selecting origin server for the request <sup>`(**)`</sup>.
- Flexible in creating your own image presets for any request.
- Flexible in serving fallback image when the source file is not available.
- Easy SSL configuration (with your own certificates) with built-in HTTP/2 support.
- Automatically detect and convert images to WebP or AVIF format if the browser supports.

<sup>`(*)` using Docker Compose.</sup>
<sup>`(**)` which is [supported by imgproxy](#supported-origin-servers).</sup>

---


## Getting started

### Prepare your files

Please put your files to be served in the folder `www/`.

There are some sample files available (a sample image `cacti.jpg`, a watermark, and some fallback images).


### Start the server

```bash
docker-compose up -d --build --remove-orphans --force-recreate
```

That's all! 😉

<small>Note: This setup requires [Docker Compose](https://docs.docker.com/compose/) installed. If you have already installed Docker Desktop or Docker Toolbox, then no need of installation for Docker Compose.</small>

If you like this setup, please [support my works](#support-my-activities) 😉.

---


## Examples

### Local images

Assuming that we want to generate various thumbnail images from the original file named `cacti.jpg`.

I already created some preset names, such as `_thumb` or `_w200`, and I add preset names to the original URL to get thumbnails from it.

> Image with no preset (it is resized to max-width=1600 as default).<br/>
> http://localhost/cacti.jpg


> The image with preset `_w200` applied (`200` is a dynamic number).<br/>
> http://localhost/_w200/cacti.jpg


> The image with preset `_blurry` applied.<br/>
> http://localhost/_blurry/cacti.jpg


> The image with preset `_small` applied.<br/>
> http://localhost/_small/cacti.jpg


> The image with preset `_medium` applied.<br/>
> http://localhost/_medium/cacti.jpg


> The image with preset `_thumb` applied.<br/>
> http://localhost/_thumb/cacti.jpg


> The image with preset `_square` applied.<br/>
> http://localhost/_square/cacti.jpg


See [my configurations](#advanced-settings) to know how it works.


### Remote images

With the same presets as above examples, we are going to serve an image [by NASA](https://www.nasa.gov/sites/default/files/thumbnails/image/esp_040663_1415.jpg) using the alias `@nasa`, that will be added in these URLs.

<small>Note: the image source is from NASA, it may be unavailable in the future.</small>

> Image with no preset (it is resized to max-width=1600 as default).<br/>
> http://localhost/@nasa/esp_040663_1415.jpg


> The image with preset `_w200` applied (`200` is a dynamic number).<br/>
> http://localhost/@nasa/_w200/esp_040663_1415.jpg


> The image with preset `_blurry` applied.<br/>
> http://localhost/@nasa/_blurry/esp_040663_1415.jpg


> The image with preset `_small` applied.<br/>
> http://localhost/@nasa/_small/esp_040663_1415.jpg


> The image with preset `_medium` applied.<br/>
> http://localhost/@nasa/_medium/esp_040663_1415.jpg


> The image with preset `_thumb` applied.<br/>
> http://localhost/@nasa/_thumb/esp_040663_1415.jpg


> The image with preset `_square` applied.<br/>
> http://localhost/@nasa/_square/esp_040663_1415.jpg


#### Supported origin servers

This setup serve images from other public origin servers, as well as from Amazon S3 buckets, Google Cloud and Azure Blob.

You can learn how to serve files from private storage in the [configurations section](#serving-files-from-private-storage).

---


## Debugging


### Debugging rewrite rule:

When you make a request with the query component `debug=1`, you will see an `X-Debug` header contains its internal `imgproxy`'s options.

Example 1 (local file with preset `_small`):
```
curl -Isk 'http://localhost/_small/cacti.jpg?debug=1'

HTTP/1.1 200 OK
Server: nginx
Content-Type: image/webp
X-Debug: /unsafe/size:320:320:0:0/sharpen:0.3/preset:logo/plain/local:///cacti.jpg@webp
```

Example 2 (remote file with preset `_w640`):
```
curl -Isk 'http://localhost/@nasa/_w640/esp_040663_1415.jpg?debug=1'

HTTP/1.1 200 OK
Server: nginx
Content-Type: image/webp
X-Debug: /unsafe/size:640:0:0:0/preset:logo/plain/https://www.nasa.gov/sites/default/files/thumbnails/image/esp_040663_1415.jpg@webp
```


### Debugging fallback image:

When you requested a file which is not available, a fallback image will be served.
There will be a 404 response with a header called `X-Fallback`, which contains the fallback image's path.

```
curl -Isk 'http://localhost/i-am-a-teacup.jpg'

HTTP/1.1 404 Not Found
Server: nginx
Content-Type: image/jpeg
X-Fallback: /noimage.jpg
```


### Other helper URL parameters:

We can use these URL query components to modify some requests.

> `skip=1`<br/>
> Skip imgproxy processing for current request. The original file will be served.<br/>
> E.g. http://localhost/cacti.jpg?skip=1

> `nocache=1`<br/>
> Disable Nginx caching for current request. The response will not be saved to a cache.<br/>
> E.g. http://localhost/cacti.jpg?nocache=1

> `bypass=1`<br/>
> By pass Nginx caching for current request. The response will not be taken from a cache.<br/>
> E.g. http://localhost/cacti.jpg?bypass=1

If you like this setup, please [support my works](#support-my-activities) 😉.

---


## Configurations


### Enabling SSL (and HTTP/2)

Create a folder `certs/` in the same place with the `docker-compose.yml` file, then rename and put your SSL certificates `server.crt` and `server.key` to that `certs/` folder.

Open the file at [`nginx/nginx.conf`](nginx/nginx.conf#L113~L116) and uncomment 4 lines right after the `# SSL` line, like this:

```nginx
# SSL
listen              443 ssl http2 reuseport;
listen              [::]:443 ssl http2 reuseport;
ssl_certificate     /etc/nginx/certs/server.crt;
ssl_certificate_key /etc/nginx/certs/server.key;
```

Then run the command in the [Start the server](#start-the-server) section to recreate and restart the service.


### Serving files from private storage

Please uncomment settings in `docker-compose.yml` file to enable serving files from [Amazon S3 buckets](docker-compose.yml#L101~L107), [Google Cloud](docker-compose.yml#L109~L112) or [Azure Blob](docker-compose.yml#L114~L119). Then run the command in the [Start the server](#start-the-server) section to recreate and restart the service.

You can find more details on [imgproxy documentation](https://docs.imgproxy.net/configuration?id=serving-files-from-amazon-s3).


### Flushing cache files

Just remove the folder `cache/`.

```bash
rm -rf cache/
```

Then run the command in the [Start the server](#start-the-server) section to restart the service.


### Advanced settings

All settings for handling image URLs are written in the [`imgproxy.conf`](imgproxy.conf#L70~L216) file using [Nginx's map directives](https://Nginx.org/en/docs/http/ngx_http_map_module.html#directives).

I keep all configurations in very simple variables. You can also make your own version from this base.


> **`$use_imgproxy`**<br/>
> This flag indicates that the request will be proceeded by `imgproxy`.
> ```nginx
> map $uri $use_imgproxy
> {
>     default 0;
>
>     # Add any rules that you want to skip image processing.
>     #> E.g. this line excludes files under "hq-cactus" folder.
>     ~^/hq-cactus/ 0;
>
>     # Else, process all image files with these file extensions
>     ~*\.(jpe?g|png|gif|tiff?|bmp)$  1;
> }
> ```


> **`$origin_server`**<br/>
> Define origin base URL from the request.
> This setup assumes that an origin server starts with an `@` symbol (such as `@nasa`, `@pinterest`, etc.).
> You can also add your own origin servers using [regular expressions](https://www.nginx.com/blog/regular-expression-tester-nginx/).
> ```nginx
> map $uri $origin_server
> {
>     default         'local://';
>
>     # Put your rewrite rules for origin servers from here.
>     #> E.g.
>     ~^/@mybucket/   's3://my-bucket';
>     ~^/@myhost/     'http://myhost.com';
>     ~^/@nasa/       'https://www.nasa.gov/sites/default/files/thumbnails/image';
>     ~^/@pinterest/  'https://i.pinimg.com/originals';
> }
> ```


> **`$origin_uri`**<br/>
> Parse real origin URI of the file.
> This setup just omits origin server and preset name in the URI if they exist,
> but you can also rewrite requested URI using [regular expressions](https://www.nginx.com/blog/regular-expression-tester-nginx/).
> ```nginx
> map $uri_omitted_origin_preset $origin_uri
> {
>     default '$uri_omitted_origin_preset';
>
>     # Put your rewrite rules for origin URI from here.
>     #> E.g. this line rewrites cactus.jpg to the real path cacti.jpg.
>     ~*^/cactus\.jpe?g$  '/cacti.jpg';
> }
> ```


> **`$preset_name`**<br/>
> Parse preset name from requested URI.
> This setup assumes that preset name starts with an underscore (`_`) symbol (such as `_thumb` or `_w200`).
> You can define your own presets using [regular expressions](https://www.nginx.com/blog/regular-expression-tester-nginx/).
> ```nginx
> map $uri_omitted_origin $preset_name
> {
>     default '';
>
>     # You can define dynamic presets,
>     #> but beware that dynamic presets are able to cause a denial-of-service attack
>     #> by allowing an attacker to request multiple different image resizes.
>     #> E.g. a dynamic preset with a variable $width.
>     # ~^/_w(?<parsed_width>[0-9_-]+)/  'max_w:${parsed_width}';
>
>     # This is a better version for above dynamic preset.
>     #> It allows only certain image sizes,
>     #> and fallbacks other undefined image sizes to max_w:200
>     ~^/_w(?<parsed_width>(200|640|800|1200|1600))/  'max_w:${parsed_width}';
>     ~^/_w(?<parsed_width>([0-9_-]+))/               'max_w:200';
>
>     # Get static preset name from the URI
>     ~^/_(?<parsed_name>[a-z0-9_-]+)/ '$parsed_name';
> }
> ```


> **`$imgproxy_preset`**<br/>
> Define `imgproxy` options for each preset name.
> ```nginx
> map $preset_name $imgproxy_preset
> {
>     default 'size:1600:0:0:0/preset:logo';
>
>     # Dynamic preset
>     ~^max_w:(?<width>[0-9]+)$ 'size:${width}:0:0:0/preset:logo';
>
>     # Static presets
>     blurry  'size:320:320:1:0/blur:10/quality:50';
>     small   'size:320:320:0:0/sharpen:0.3/preset:logo';
>     medium  'size:640:640:0:0/preset:logo';
>     thumb   'size:160:160:1:1/bg:ffffff/resizing_type:fill/sharpen:0.3';
>     square  'size:500:500:0:1/bg:ffffff/resizing_type:fill/preset:center_logo';
> }
> ```


> **`$imgproxy_extension`**<br/>
> Detect WebP or AVIF supports from the request header `Accept`.
> ```nginx
> map $http_accept $imgproxy_extension
> {
>     default '';
>     ~*webp  '@webp';
>     ~*avif  '@avif';
> }
> ```


> **`$imgproxy_options`**<br/>
> Generate final URL for `imgproxy` following [their documentation](https://docs.imgproxy.net/generating_the_url).
> When URL query `?skip=1` is set, use another rule to skip `imgproxy` processing.
> ```nginx
> map $arg_skip $imgproxy_options
> {
>     default '/unsafe/${imgproxy_preset}/plain/${origin_server}${origin_uri}${imgproxy_extension}';
>     ~.+     '/unsafe/plain/${origin_server}${origin_uri}';
> }
> ```


> **`$fallback_uri`**<br/>
> Define fallback file to serve when the requested file is unavailable.
> E.g. `/noimage.jpg` or `/noimage_thumb.jpg`, which is stored in the folder `www/`.
> ```nginx
> map $preset_name $fallback_uri
> {
>     default '/noimage.jpg';
>     thumb   '/noimage_thumb.jpg';
>     # small   '/noimage_small.jpg';
>     # medium  '/noimage_medium.jpg';
>     # square  '/noimage_square.jpg';
> }
> ```


I think you can even make a better version than mine 😊.


* * *

If you like this project, please [support my works](#support-my-activities) 😉.

From Vietnam 🇻🇳 with love.
