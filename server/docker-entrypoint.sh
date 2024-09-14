#!/usr/bin/env sh
#
#
set -e

_want_init() {
	local arg
	for arg; do
		case "$arg" in
			# postgres --help | grep 'then exit'
			# leaving out -C on purpose since it always fails and is unhelpful:
			# postgres: could not access the server configuration file "/var/lib/postgresql/data/postgresql.conf": No such file or directory
			--init|-init|-i)
				return 0
				;;
		esac
	done
	return 1
}

CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"

# if command starts with an option, prepend omni-server
if [ "${1:0:1}" = '-' ]; then
    exec omni-server "$@"
fi
# cd workspace

if [ ! -e /metadata/$CONTAINER_FIRST_STARTUP ] && ! _want_init "$@"; then
    touch /metadata/$CONTAINER_FIRST_STARTUP
    # place your script that you only want to run on first startup.
    omni-server -conf ${CONFIG_FILE} -init
fi

# if command app only, add use default args
if [ "$1" = 'omni-server' ] ; then
    exec omni-server -conf ${CONFIG_FILE}
fi

exec "$@"
