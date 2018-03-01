safe_source () {
    eval " \
        source $1 \
    ";
    local version=${DEFAULT_VERSION:-}
    unset DEFAULT_VERSION
    echo $version
}

install_ext () {
    local ext=$1
    local reason=${2:-}
    local ext_ini="$BP_DIR/conf/php/conf.d/ext-$ext.ini"
    local ext_so=
    local ext_dir=$(php-config --extension-dir)
    local ext_api=$(basename $ext_dir)
    local ext_buildpack="$BP_DIR/support/build/extensions/$ext_api/$ext"

    # this will load the default version
    local version=`safe_source $ext_buildpack`

    # if we have an ini config for the extension then we can install it
    if [[ -f "$ext_ini" ]]; then
        ext_so=$(php -r '$ini=parse_ini_file("'$ext_ini'"); echo $ext=$ini["zend_extension"]?:$ini["extension"]; exit((int)empty($ext));') # read .so name from .ini because e.g. opcache.so is named "zend-opcache"
        notice_inline "ext - [ext:$ext] [version:$version] [so:$ext_so] [api:$ext_api]"
        notice_inline "ext - [ext_dir:$ext_dir]"
        notice_inline "ext - [ext_buildpack:$ext_buildpack]"

        # if <ext>.so is not in the env, then we need to try add it
        if [[ ! -f "$ext_dir/$ext_so" ]]; then
            # if it exists then install the ext from heroku's repo
            if [[ -f "$ext_buildpack" ]]; then
                cachecurl "${S3_URL}/extensions/${ext_api}/${ext}-${version}.tar.gz" | tar xz -C $BUILD_DIR/.heroku/php
                echo "- ${ext} (${reason}; downloaded)" | indent
                cp "${ext_ini}" "${BUILD_DIR}/.heroku/php/etc/php/conf.d"
            else
                warning_inline "Unknown extension ${ext} (${reason}), install may fail!"
            fi
        else
            echo "- ${ext} (${reason}; bundled)" | indent
            cp "${ext_ini}" "${BUILD_DIR}/.heroku/php/etc/php/conf.d"
        fi
    elif [[ -f "${ext_dir}/${ext}.so" ]]; then
        echo "extension = ${ext}.so" > "${BUILD_DIR}/.heroku/php/etc/php/conf.d/ext-${ext}.ini"
        echo "- ${ext} (${reason}; bundled)" | indent
    elif echo -n ${ext} | php -r 'exit((int)!extension_loaded(file_get_contents("php://stdin")));'; then
        echo "- ${ext} (${reason}; enabled by default)" | indent
    else
        warning_inline "Unknown extension ${ext} (${reason}), install may fail!"
    fi
}