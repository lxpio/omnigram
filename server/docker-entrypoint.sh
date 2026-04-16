#!/usr/bin/env sh
#
#
set -e

_want_init() {
	local arg
	for arg; do
		case "$arg" in
			--init|-init|-i)
				return 0
				;;
		esac
	done
	return 1
}

CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"

# 检查 /metadata 目录可写（bind mount 时常见的权限问题）
if [ ! -w /metadata ]; then
    echo "=========================================="
    echo "  ERROR: /metadata directory is not writable!"
    echo "  The container runs as uid 1000 (omnigram)."
    echo ""
    echo "  If using a bind mount, fix host directory ownership:"
    echo "    sudo chown -R 1000:1000 /path/to/your/data"
    echo ""
    echo "  If using a Docker named volume, fix it with:"
    echo "    docker run --rm -v <volume_name>:/metadata alpine chown -R 1000:1000 /metadata"
    echo "=========================================="
    exit 1
fi

# 如果未设置用户名/密码，生成随机密码
if [ -z "$OMNI_USER" ]; then
    export OMNI_USER="admin"
fi
if [ -z "$OMNI_PASSWORD" ]; then
    OMNI_PASSWORD=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | head -c 16)
    export OMNI_PASSWORD
    echo "=========================================="
    echo "  Generated admin password: $OMNI_PASSWORD"
    echo "  Username: $OMNI_USER"
    echo "  Change it after first login!"
    echo "=========================================="
fi

# if command starts with an option, prepend omni-server
if [ "${1:0:1}" = '-' ]; then
    exec omni-server "$@"
fi

if [ ! -e /metadata/$CONTAINER_FIRST_STARTUP ] && ! _want_init "$@"; then
    touch /metadata/$CONTAINER_FIRST_STARTUP
    omni-server -conf ${CONFIG_FILE} -init
fi

# if command app only, add use default args
if [ "$1" = 'omni-server' ] ; then
    exec omni-server -conf ${CONFIG_FILE}
fi

exec "$@"
