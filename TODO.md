Notes:
* all config files (php, nginx, apache and both include and full) go through a passthrough that is environment aware
    * so if it has .php then it will get processed by php
    * if not it has bash variable substitution like `${PORT}`
* document WEB_CONCURRENCY=auto and default=6

# Todo
* run scripts need to refer to buildpack location from packager/compile not from the composer buildpack
* `command scale web=32` sets nothing?
    * should it set `WEB_CONCURRENCY` or httpd/nginx workers
* port/refactor extensions:
    * `no-debug-non-zts-20160303/*`
    * `no-debug-non-zts-20170718/*`
    * `ampq`
    * `ev`
    * `event`
    * `cassandra`
    * `mongodb`
    * `phalcon2`
    * `phalcon3`
    * `pq`
    * `raphf`
    * `rdkafka`
    * `ctwig`
* strip unneeded files

