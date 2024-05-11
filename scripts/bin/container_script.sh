

# Check if exists devcontainer associated with this directory
container_id=$(docker ps -q -a --filter label=devcontainer.local_folder=$PWD)
#echo "Container id: $container_id"

if [ ! -z $container_id ]; then
#	echo "There is a container"
	container_status=$(docker inspect --format='{{ .State.Status }}' $container_id)
	
	if [ $container_status = exited ]; then
		echo "Container not running. Starting it..."
		docker start $container_id >/dev/null 2>&1
	fi

	work_dir=$(docker inspect --format '{{ (index .Mounts 0).Destination }}' $container_id)
#	echo "Working directory in container: $work_dir"
	docker container exec -it --workdir $work_dir $container_id zsh
else
	echo "No container found at this directory"
	echo "Build one with devcontainer.json"
	sleep 2;
fi
