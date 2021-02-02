#!/usr/bin/env bash

/opt/app_protect/bin/get-signatures -o /tmp/unformatted-signature-report.json | jq

jq --sort-keys . /tmp/unformatted-signature-report.json > /tmp/signature-report.json

rm /tmp/unformatted-signature-report.json
