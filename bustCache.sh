docker ps -a --format "{{.Names}}" | grep dagger | xargs docker stop
docker ps -a --format "{{.Names}}" | grep dagger | xargs docker rm

