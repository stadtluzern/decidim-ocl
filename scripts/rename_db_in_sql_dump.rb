#!/usr/bin/env bash
# vim: et:ts=2:sw=2:tw=0:wm=0:fdm=marker

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "I need 3 params: ${1:-<sql file>} ${2:-<old db>} ${3:-<new_db>}"
  exit 1
fi


sql_file="${1}"
old_db="${2}"
new_db="${3}"
temp_file=$(mktemp)

head -n 100 "${sql_file}" | sed "s/${old_db}/${new_db}/" > "${temp_file}"

sed -i "1,100{R ${temp_file}
d}" "${sql_file}"
