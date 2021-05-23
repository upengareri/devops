# Docker basics
- Used for running containerized applications
- Check additional notes on docker here as well - [../../../jupyter_projects/Notes.ipynb](../../../jupyter_projects/Notes.ipynb)
## Basic docker commands
__Containers__
- `docker run <image>` start a container (will download the image from docker hub if not found locally)
- `docker ps` list running containers
- `docker ps -a` list running + stopped containers (-a: all)
- `docker stop <container_name>` to stop a container
- `docker rm <stopped_container>` to remove stopped container

__Images__
- `docker images` list all images
- `docker rmi <image>` delete image
> delete all dependent containers to remove image
- `docker pull <image>` to download the image from docker hub

------
- unlike virtual hosts, docker is not meant to run OS e.g ubuntu. Docker container will run as long as any process inside it is running and docker OS e.g `docker run ubuntu` does not run any process by itself and that is why the container will exit as soon as you run it
- containers are meant to run only specific tasks or process/services e.g  to host application server or web server or database or some kind of analysis or computational task
- a container lives as long as the process inside it lives. If the web service (as an example) inside it is stopped or crashed, the container exits
-----
- `docker run <image> <command>` to run any command/process __while starting__ the container e.g `docker run ubuntu sleep 5`
- `docker exec <container> <command>` to execute a command on a running container

__Run - attach and detach__
- `docker run -d <image>` run container in background (detached state)
- `docker attach <container_id>` bring container to foreground i.e to console stdout (attached state)
> to exit from foreground, you need to quit the process e.g by CTRL+C
-----
__Run - STDIN__ (`-it` flags)
- Let's say we have an application "app.sh" that asks for our name and then greets us e.g
    ![greet app](./images/it_flag.png)
    - __First scenario:__ we run the application script; it provides a message and asks us for input
    - __Second scenario:__ we run the application using docker; it doesn't provide a message nor does it asks us for input; but directly prints the final message; this is because the container terminal is not interacting with our terminal
    - __Third scenario:__ we run the docker app with `-i` flag; now it prompts for the user input; this is because the flag is allowing us to interact with the docker app; but we still can't see the message "Welcome! Please enter your name: "
    - __Fourth scenario:__ we run the docker app with an additional `-t` flag; this is showing us the message in stdout; the flag `-t` is for stdout terminal
    > We use `-it` flag with `docker run` while running the application to interact with the terminal of the docker container
-----
> The underlying host where docker is installed is called __docker host__ or __docker engine__

__Run - Port Mapping__ (`-p` flag)
- docker container gets its own IP
- If we are running a containerized web application that listens on port 5000 then there are 2 options to reach to web app
    - 1. we use the internal docker IP and port e.g `http://172.17.0.2:5000`. But as the IP is an internal one, user outside the docker host won't be able to access it.
    - 2. we can use the docker host IP by mapping free port of docker host to the port of docker container by `docker run -p 80:5000 kodekloud/simple-webapp` and thus access it outside the docker host by using `http://192.168.1.5:80` as an example from the image
    - Similary we can run multiple instances by running them on multiple ports of docker host
    - Also, we can run multiple applications by exposing them on unique free ports of docker host
    - Note: we cannot run two applications on same port
    ![port mapping](./images/port_mapping.png)
-----
__Run - Volume Mapping__ (`-v` flag)
- docker container has its own separate filesystem isolated from docker host
- this means if the container is gone, the data stored in the filesystem is gone
- to keep data persistent outside the container we can map it to filesystem of docker host e.g
    `docker run -v /opt/datadir:/var/lib/mysql mysql` as shown in the below image
    ![volume mapping](./images/volume_mapping.png)
- `docker ps` gives info about the containers running but to get detailed info about a container one can use `docker inspect <container_name>`
- `docker inspect <container/image>` detailed info in json format about the container such as IP, volume mounts etc.
- `docker logs <container_name>` to check the logs produced by the containerized app
-----
__Run - Environment Variable__ (`-e` flag)
- `docker run -e NAME=value <image>` passes NAME=value as the environment variable to the container
> To check the environment variable passed to a container use `docker inspect <container>`
-----