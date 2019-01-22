#!/bin/bash

echo "# starting container"
docker run -d -p 8000:8000 -p 9000:9000 --name "${docker_container_name}" "${docker_img}:${docker_img_tag}" sudo mysqld start
docker exec -d "${docker_container_name}" bench start

echo "# waiting for container to start"
sleep 120s

echo "# debug"
echo "## docker logs"
docker logs "${docker_container_name}"
echo "## docker inspect"
docker inspect "${docker_container_name}"

echo "# test html response"
html_response = $(docker exec "${docker_container_name}" python test_server.py)
echo "${html_response}"

echo "# remove container"
docker rm -f "${docker_container_name}"

echo "# push image"
if [ "${html_response}" == "200" ]; then
    docker push "${docker_img}:${docker_img_tag}"

else
    echo "ERROR! : Html reponse is '${html_response}' not 200"
    exit 1
fi