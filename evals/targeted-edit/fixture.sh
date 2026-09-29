#!/usr/bin/env bash
set -e
{
  echo '"""Service settings. Generated fixture: one constant per block."""'
  echo
  for i in $(seq 1 50); do
    printf '# block %d\nSETTING_%03d = %d\nSETTING_%03d_ENABLED = True\n\n\ndef describe_%03d():\n    return "setting %d"\n\n' "$i" "$i" "$i" "$i" "$i" "$i"
    [ "$i" -eq 25 ] && printf '# retry policy\nMAX_RETRIES = 3\nRETRY_BACKOFF_SECONDS = 2\n\n'
  done
  echo '# end of settings'
} > settings.py
