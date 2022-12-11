# shellcheck disable=SC2046
kill -9 $(lsof -t -i:8080)
echo "port cleaned up"