#!/bin/sh
sh -c "sleep 2; open http://localhost:8123" &
gollum --port 8123
