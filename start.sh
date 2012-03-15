#!/bin/sh

# Start Gollum on current branch 

branch_name=$(git symbolic-ref -q HEAD)
branch_name=${branch_name##refs/heads/}
branch_name=${branch_name:-HEAD}

port=8223;

echo "launching gollum on branch:    $branch_name   \n Ctrl+C to quit"

sh -c "sleep 2; open http://localhost:$port" &
gollum --ref $branch_name --port $port
