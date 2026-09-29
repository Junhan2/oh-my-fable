#!/usr/bin/env bash
set -e
mkdir -p services
printf 'SERVICE=api\nTIMEOUT_SECONDS=30\nWORKERS=4\nLOG_LEVEL=info\n' > services/api.env
printf 'SERVICE=worker\nTIMEOUT_SECONDS=120\nWORKERS=8\nLOG_LEVEL=info\n' > services/worker.env
printf 'SERVICE=cron\nTIMEOUT_SECONDS=600\nWORKERS=1\nLOG_LEVEL=debug\n' > services/cron.env
