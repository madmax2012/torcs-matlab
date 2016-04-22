## Installation
### Fetch sources
```
  git clone https://github.com/madmax2012/torcs-matlab.git
  cd torcs-matlab
```
### Install dependencies
```
  sudo apt-get install -y mesa-common-dev freeglut3-dev libplib-dev libalut-dev vorbis-tools libvorbis-dev libxi6 libxi-dev libxmu-dev libxrender-dev libxrandr2 zlib1g-dev libpng3 libpng++-dev openssh-server libxrandr-dev
```
### Install TORCS 

```  
  ./configure
  make
  sudo make install
  make datainstall
```

### Install TORCS 

Copy the 3001.xml config to a directory of your choice
<br>
Open MatlabExample.m and point TorcsConfigBase  to your chosen config Directory
