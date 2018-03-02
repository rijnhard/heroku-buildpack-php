cachecurl() {
	local cache_dir="$CACHE_DIR/cachecurl"
	local binary=$(basename $1 .tar.gz)
	local recipe=${binary/-*/}
	local version=${binary/*-/}
	local output=$(mktemp)

	notice_inline "Cachecurl ($1) for binary:$binary in output:$output but to $cache_dir/$binary.tar.gz"
	mkdir -p "$cache_dir"
	if [ ! -f $cache_dir/$binary.tar.gz ]; then
		notice_inline "         Downloading Binary for the first time"
		curl -sSL --get --retry 3 $1 \
			-o $output && gunzip -t $output &>/dev/null || ( cat $output 1>&2 && exit 1 )
		mv $output $cache_dir/$binary.tar.gz
	fi
	cat $cache_dir/$binary.tar.gz
}

buildcurl() {
	local cache_dir="$CACHE_DIR/buildcurl"
	local binary=$(basename $1 .tar.gz)
	local recipe=${binary/-*/}
	local version=${binary/*-/}
	local out_prefix=${2:-"/app/.heroku/php"}
	local output=$(mktemp)

	notice_inline "Buildcurl ($1) for binary:$binary output:$output to out_prefix:$out_prefix"
	mkdir -p "$cache_dir"
	if [ ! -f $cache_dir/$binary.tar.gz ]; then
		notice_inline "         Compiling $binary for the first time will take a few minutes..."
		curl -sSL --get --retry 3 ${BUILDCURL_URL:="buildcurl.com"} \
			--data-urlencode recipe=$recipe \
			--data-urlencode version=$version \
			--data-urlencode target=$TARGET \
            --data-urlencode prefix=$out_prefix \
			-o $output

		gunzip -t $output &>/dev/null || ( cat $output 1>&2 && exit 1 )
		mv $output $cache_dir/$binary.tar.gz
	fi
	cat $cache_dir/$binary.tar.gz
}