#!/bin/bash

set -e

# Add grafana as command if needed
if [[ "$1" == -* ]]; then
	set -- grafana "$@"
fi

# Run as user "grafana" if the command is "grafana-server web"
if [ "$1" = 'grafana-server web' ]; then
	set -- gosu grafana "$@"
fi

exec "$@"
