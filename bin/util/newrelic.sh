#!/usr/bin/env bash

install_newrelic_ext() {
    # special treatment for New Relic; we enable it if we detect a license key for it
    # otherwise users would have to have it in their require section, which is annoying in development environments
    NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY:-}
    if [[ "$engine" == "php" && -n "$NEW_RELIC_LICENSE_KEY" ]] && ! $engine -n $(which composer) show -d "$BUILD_DIR/.heroku/php" --installed --quiet heroku-sys/ext-newrelic 2>/dev/null; then
        if $engine -n $(which composer) require --update-no-dev -d "$BUILD_DIR/.heroku/php" -- "heroku-sys/ext-newrelic:*" >> $BUILD_DIR/.heroku/php/install.log 2>&1; then
            echo "- New Relic detected, installed ext-newrelic" | indent
        else
            warning_inline "New Relic detected, but no suitable extension available"
        fi
    fi
}

install_newrelic_daemon() {
    # new relic defaults
    cat > $BUILD_DIR/.profile.d/newrelic.sh <<"EOF"
if [[ -n "$NEW_RELIC_LICENSE_KEY" ]]; then
    if [[ -f "/app/.heroku/php/bin/newrelic-daemon" ]]; then
        export NEW_RELIC_APP_NAME=${NEW_RELIC_APP_NAME:-"PHP Application on Heroku"}
        export NEW_RELIC_LOG_LEVEL=${NEW_RELIC_LOG_LEVEL:-"warning"}
        # The daemon is a spawned process, invoked by the PHP agent, which is truly
        # daemonized (i.e., it is disassociated from the controlling TTY and
        # running in the background). Therefore, the daemon is configured to write
        # its log output to a file instead of to STDIO
        # (see .heroku/php/etc/php/conf.d/ext-newrelic.ini).
        #
        # Perpetually tail and redirect the daemon log file to stderr so that it
        # may be observed via 'heroku logs'.
        touch /tmp/heroku.ext-newrelic.newrelic-daemon.${PORT}.log
        tail -qF -n 0 /tmp/heroku.ext-newrelic.newrelic-daemon.${PORT}.log 1>&2 &
    else
        echo >&2 "WARNING: Add-on 'newrelic' detected, but PHP extension not yet installed. Push an update to the application to finish installation of the add-on; an empty change ('git commit --allow-empty') is sufficient."
    fi
fi
EOF
}

install_newrelic_userini() {
    if [[ "$engine" == "php" && -n "${NEW_RELIC_CONFIG_FILE:-}" ]]; then
        if [[ ! -f "${NEW_RELIC_CONFIG_FILE}" ]]; then
            error "Config var 'NEW_RELIC_CONFIG_FILE' points to non existing file
'${NEW_RELIC_CONFIG_FILE}'"
        fi
        notice_inline "Using custom New Relic config '${NEW_RELIC_CONFIG_FILE}'"
        ( cd $BUILD_DIR/.heroku/php/etc/php/conf.d; ln -s "../../../../../${NEW_RELIC_CONFIG_FILE}" "ext-newrelic.user.ini" )
    fi
}
