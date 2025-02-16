# **Jason BDI Agents for UAV Control in PX4 SITL Search and Rescue Simulation**
Examples of Embedded-MAS at /Agents , more details at https://github.com/embedded-mas/embedded-mas/tree/master/examples/jacamo/ros

Example of Gustavo Old Code at /src/Gustavo, more details at https://github.com/Rezenders/active-perception-experiments
## **Introduction**



This project demonstrates the use of **Jason BDI (Belief-Desire-Intention) agents** to control **Unmanned Aerial Vehicles (UAVs)** in a **PX4 SITL (Software In The Loop)** search and rescue simulation. The goal is to showcase the application of **BDI cognitive architectures** in autonomous UAV systems, focusing on their ability to plan and execute search and rescue missions in simulated environments.

In this setup, the UAVs are controlled by **BDI agents**, which operate within the **ROS Noetic** environment. The simulation leverages **PX4-Autopilot** for realistic flight dynamics and **Gazebo** for simulation of the UAV's environment. The **rosbridge-suite** is used to facilitate communication between ROS and external applications.

---

## **Installation Setup (Without Docker)**

If you'd like to run this project **without Docker**, follow the steps below to install and set up the required dependencies manually on an Ubuntu 20.04 system.

### **1. Install System Dependencies**

Run the following commands to install the required system dependencies:

```bash
sudo apt update
sudo apt install -y     git     wget     lsb-release     sudo     curl     unzip     build-essential     cmake     ninja-build     protobuf-compiler     libeigen3-dev     libgstreamer1.0-dev     libgstreamer-plugins-base1.0-dev     libgazebo11-dev     libopencv-dev     libprotobuf-dev     libprotoc-dev     python3-pip     python3-rosdep     python3-rosinstall     python3-rosinstall-generator     python3-wstool     python3-catkin-tools     ros-noetic-catkin     ros-noetic-rosbridge-suite
```

### **2. Install ROS Noetic**

Follow the ROS installation steps for **Noetic**:

```bash
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -sSL 'http://packages.ros.org/ros.key' | sudo apt-key add -
sudo apt update
sudo apt install -y ros-noetic-desktop-full
```

Then, initialize and update `rosdep`:

```bash
sudo rosdep init
rosdep update
```

Add the following to your `~/.bashrc` to source ROS:

```bash
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### **3. Install PX4-Autopilot**

Clone the **PX4-Autopilot** repository and set it up:

```bash
git clone --recursive https://github.com/PX4/PX4-Autopilot.git ~/PX4-Autopilot
cd ~/PX4-Autopilot
bash ./Tools/setup/ubuntu.sh
```

### **4. Install MAVROS and Dependencies**

MAVROS allows ROS to communicate with PX4. Install it with:

```bash
sudo apt install ros-noetic-mavros ros-noetic-mavros-extras ros-noetic-geographic-msgs
```

Download the required **GeographicLib datasets**:

```bash
wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
chmod +x install_geographiclib_datasets.sh
./install_geographiclib_datasets.sh
```

### **5. Install Java 21 (JDK)**

Install **Java 21 (OpenJDK)**:

```bash
sudo apt update
sudo apt install -y openjdk-21-jdk
echo "export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64" >> ~/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc
```

### **6. Install Jason BDI**

Clone the **Jason BDI** repository and build it:

```bash
git clone https://github.com/jason-lang/jason.git ~/jason
cd ~/jason
./gradlew config
echo "export JASON_HOME=~/jason" >> ~/.bashrc
echo "export PATH=\$JASON_HOME/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc
```

### **7. Set Up Catkin Workspace**

Create a **catkin workspace** for ROS and clone the project repository:

```bash
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src
git clone https://github.com/iago-silvestre/search-rescue-px4.git
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
catkin_make
```
---

## **Environment Variables**

The following environment variables are set in your `~/.bashrc` for the project to work:

```bash
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
echo "source ~/PX4-Autopilot/Tools/setup_gazebo.bash ~/PX4-Autopilot ~/PX4-Autopilot/build/px4_sitl_default" >> ~/.bashrc
echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/PX4-Autopilot" >> ~/.bashrc
echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic" >> ~/.bashrc
echo "export GAZEBO_PLUGIN_PATH=\$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins" >> ~/.bashrc
echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:~/catkin_ws" >> ~/.bashrc
echo "export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:~/catkin_ws/src/search-rescue-px4/models" >> ~/.bashrc
source ~/.bashrc
```

These variables are sourced automatically when you start a new shell.

---
## **Installation Setup (With Docker)**
Alternatively, you can run this setup using Docker. For [Windows](https://docs.docker.com/desktop/setup/install/windows-install/) it is recommended to have [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) installed.
1. **Clone the repository**:
   ```bash
   git clone https://github.com/iago-silvestre/search-rescue-px4.git
   cd search-rescue-px4
   ```

2. **Build the Docker image**:
   ```bash
   docker build -t px4_jason .
   ```
---

### **For Windows Users (with VCXsrv)**

1. **Install VCXsrv** from [here](https://github.com/marchaesen/vcxsrv) and start it with XLaunch using default settings.
   
2. **Set the DISPLAY environment**:
Set the `DISPLAY` to point to the host machine’s X11 server:
     ```bash
     set DISPLAY=host.docker.internal:0
     ```

3. **Run the container**:
   ```bash
   docker run -it --rm --env DISPLAY=host.docker.internal:0 --volume /tmp/.X11-unix:/tmp/.X11-unix --env QT_X11_NO_MITSHM=1 --net host px4_jason
   ```

---

### **For Linux Users**

1. **Allow Docker to access the X11 server**:
   ```bash
   xhost +local:docker
   ```

2. **Run the container**:
   ```bash
   docker run -it --rm --env DISPLAY=$DISPLAY --volume /tmp/.X11-unix:/tmp/.X11-unix --env QT_X11_NO_MITSHM=1 --net host px4_jason
   ```
   

---

## **How to Use the Setup**
Start by running the Gazebo Simulation and spawning the PX4 UAVs
```bash
roslaunch search-rescue-px4 multi_uav_mavros_sitl.launch 
```

*(More Instructions to be filled in later)*

---



## **Acknowledgments**

- **PX4-Autopilot**: Open-source flight control software for UAVs.
- **ROS**: The Robot Operating System (ROS) provides the framework for controlling and simulating the UAV.
- **Jason BDI**: A framework for implementing BDI (Belief-Desire-Intention) agent-based systems.
- **Gazebo**: A simulation platform for testing robots in realistic environments.

