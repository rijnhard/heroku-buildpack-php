#!/usr/bin/env bash

install_blackfire_ext() {
    # special treatment for Blackfire; we enable it if we detect a server id and a server token for it
    # otherwise users would have to have it in their require section, which is annoying in development environments
    BLACKFIRE_SERVER_ID=${BLACKFIRE_SERVER_ID:-}
    BLACKFIRE_SERVER_TOKEN=${BLACKFIRE_SERVER_TOKEN:-}
    if [[ "$engine" == "php" && -n "$BLACKFIRE_SERVER_TOKEN" && -n "$BLACKFIRE_SERVER_ID" ]] && ! $engine -n $(which composer) show -d "$BUILD_DIR/.heroku/php" --installed --quiet heroku-sys/ext-blackfire 2>/dev/null; then
        if $engine -n $(which composer) require --update-no-dev -d "$BUILD_DIR/.heroku/php" -- "heroku-sys/ext-blackfire:*" >> $build_dir/.heroku/php/install.log 2>&1; then
            echo "- Blackfire detected, installed ext-blackfire" | indent
        else
            warning_inline "Blackfire detected, but no suitable extension available"
        fi
    fi
}

install_blackfire_agent() {
    # blackfire defaults
    cat > $BUILD_DIR/.profile.d/blackfire.sh <<"EOF"
if [[ -n "$BLACKFIRE_SERVER_TOKEN" && -n "$BLACKFIRE_SERVER_ID" ]]; then
    if [[ -f "/app/.heroku/php/bin/blackfire-agent" ]]; then
        touch /app/.heroku/php/var/blackfire/run/agent.sock
        /app/.heroku/php/bin/blackfire-agent -config=/app/.heroku/php/etc/blackfire/agent.ini -socket="unix:///app/.heroku/php/var/blackfire/run/agent.sock" &
    else
        echo >&2 "WARNING: Add-on 'blackfire' detected, but PHP extension not yet installed. Push an update to the application to finish installation of the add-on; an empty change ('git commit --allow-empty') is sufficient."
    fi
fi
EOF
}