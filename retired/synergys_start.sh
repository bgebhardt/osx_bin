#!/bin/sh

# start up synergy server
killall synergys; /usr/bin/synergy-1.3.1/synergys -f --config ~/synergy.conf &

