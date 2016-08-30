buildcurl() {
	local cache_dir="$cache_dir/buildcurl"
	local binary=$(basename $1 .tar.gz)
	local recipe=${binary/-*/}
	local version=${binary/*-/}
	local out_prefix="$build_dir/.heroku/php"
	local output=$(mktemp)

	status "Buildcurl ($1) for binary:$binary output:$output to out_prefix:$out_prefix"
	mkdir -p "$cache_dir"
	if [ ! -f $cache_dir/$binary.tar.gz ]; then
		echo "         Compiling $binary for the first time will take a few minutes..." 1>&2
		curl -sSL --get --retry 3 ${BUILDCURL_URL:="buildcurl.com"} \
			-d recipe=$recipe -d version=$version -d target=$TARGET -d prefix=$out_prefix \
			-o $output && gunzip -t $output &>/dev/null || ( cat $output 1>&2 && exit 1 )
		mv $output $cache_dir/$binary.tar.gz
	fi
	cat $cache_dir/$binary.tar.gz
}
