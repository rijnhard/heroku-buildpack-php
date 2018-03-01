# Todo

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