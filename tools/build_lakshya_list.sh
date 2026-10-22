#!/usr/bin/env bash
# Builds the home blocklist: HaGeZi Pro + HaGeZi DoH (blocks encrypted-DNS
# bypass) + lists/extra-block.txt, minus lists/allow.txt. Refuses to write
# output if anything in lists/must-work.txt would be blocked.
# usage: tools/build_lakshya_list.sh OUT.bin
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/build_blocklist.py "$1" \
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro-onlydomains.txt \
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/doh-onlydomains.txt \
  lists/extra-block.txt \
  --allow lists/allow.txt \
  --must-work lists/must-work.txt
# Sanity: a real list is > 100k domains; refuse to publish a tiny one
# (e.g. a source download that silently failed).
n=$(python3 -c "import sys,struct;d=open(sys.argv[1],'rb').read();print(struct.unpack('<I',d[6:10])[0])" "$1")
echo "domains: $n"
if [ "$n" -lt 100000 ]; then echo "!! only $n domains — refusing"; rm -f "$1"; exit 3; fi
