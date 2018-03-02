Notes:
* all config files (php, nginx, apache and both include and full) go through a php_passthrough that is environment aware

# Todo
* run scripts need to refer to buildpack location from packager/compile not from the composer buildpack
* `command scale web=32` sets nothing?
    * should it set `WEB_CONCURRENCY` or httpd/nginx workers
* add way to control nginx workers (should be injected in the compile script)
* remove all teleforge http nginx configs
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
* re-enable apache
    * package nginx and apache only if they have a command in the Procfile
* strip unneeded files

