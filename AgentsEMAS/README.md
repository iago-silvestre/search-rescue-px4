# E-Mas agents for the Search and Rescue project
### 1. Launch the Docker containers:
#### Windows
```
set DISPLAY=host.docker.internal:0

docker run -it --rm --env DISPLAY=host.docker.internal:0 --volume /tmp/.X11-unix:/tmp/.X11-unix --env QT_X11_NO_MITSHM=1 --volume .\Agents:/root/Agents --net host px4_jason

```
Change the volume directory for the agents to match your local one.

### 2. Launch the JaCaMo application:

#### On the container:
```
cd /root/Agents
chmod +x gradlew
./gradlew run
```
