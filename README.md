# What is cpu-fan?

**cpu-fan** is script used to aid with setup of dynamic control of CPU FAN
speed, on motherboards using chip which in turn is controlled with
**nct6775** kernel module. Following chips are supported (at the time
of this writing):
<ul>

```
Nuvoton NCT6102D NCT6104D NCT6106D
Nuvoton NCT5572D NCT6771F NCT6772F NCT6775F W83677HG-I
Nuvoton NCT5573D NCT5577D NCT6776D NCT6776F
Nuvoton NCT5532D NCT6779D
Nuvoton NCT6791D
Nuvoton NCT6792D
Nuvoton NCT6793D
Nuvoton NCT6795D
Nuvoton NCT6795D
```

</ul>

**cpu-fan** only supports mode **5** (***Smart Fan IV mode***). In that
mode, speed of fan is dependent of CPU temperature, and relation
between fan speed and CPU temperature is defined with curve, which
in turn is defined by slopes between up to **7** points (depending on
the chip type). If your motherboard does not use **cnt6775** kernel  module
or if chip does not support ***Smart Fan IV mode***, than this script is
of no use to you.




# How it works?
The fan itself is controlled with **nct6775** kernel model, and not by
**cpu-fan** script. The role of **cpu-fan** script is to set kernel module
parameters, which in turn will enforce CPU FAN control.
This is done when **cpu-fan** is setup, and when system is booted up (using
**systemd** service).


# Prerequisites

**zsh shell**
<ul>

**cpu-fan** is **zsh** script. If one is not present on the system installation
will fail.
</ul>


**lm-sensors tools**
<ul>

**lm-sensors tools** are used to identify needed kernel module(s), and if
proper one is detected to retrieve status of the fan/CPU (cpu temperature
and fan speed).  To detect motherboard chip in use for control of fan speed,
```
sensors-detect
```
script has to be run. Once required chips are found, add them them to the
list of modules to be loaded at boot. This can be also done by answering `yes`
when asked by the script. You can accept default answers asked by the script.

After modules have been detected, either run:
```
sudo modprobe coretemp
sudo modrpobe nct6775
```
or restart your PC.

</ul>

# Installation
Clone repository to your system, cd to **cpu-fan** directory and run:
```
sudo make install
```
This will install **cpu-fan** script into `/usr/local/bin` directory.
It will also install **systemd** unit file. Autocompletion configuration
files for **bash** and **zsh** will also be installed as part of installation
process (if given shells are installed on system). If given shell is installed
afterwards, repeat installation process to install missing autocompletion files.

You can remove **cpu-fan** from system by running
```
sudo make uninstall
```
This will also remove configuration file `/etc/cpu-fan.conf` if one has been
created.

# Setup
After (and if) proper chip has been detected, and **nct6775** kernel module
has been loaded, we have to configure needed parameters by running:
```
sudo cpu-fan setup
```
**Script will aid you to do following**:

 1. Identify controller responsible for your **CPU FAN**
 2. Detect proper number of pulses per fan revolution
 3. Define temperature/speed profile for fan control
 4. Activate fan control
 5. Enable boot time activation

<br>

**1. controller**

<ul>

There are multiple controllers on your board (power connectors intended for
fans), and you could also have multiple fans connected to them. Only one will
control the **CPU FAN**. To identify the controller, script will speed up any
fan attached to controller, and your task will be to see (or hear) when **CPU FAN**
speeds up. When you detect it, answer affirmative to the script.
</ul>

**2. number of pulses**

<ul>

Number of pulses is kernel parameter, which affects reported fan speed. It has
to be properly selected, so reported speed will be correct. Script will cycle
through possible values, and you will be presented with the list of detected
fan speeds. Select the value which is closes to **maximum** fan speed declared
for your fan.
</ul>

**3. temperature/speed profile**

<ul>

**FAN** speed is defined with the curve, which in turn is defined with up to
**7** points. Each point is given by **temperature** and corresponding
**fan speed**. When CPU reaches given temperature, FAN will have
specified speed. CPU **temperature** is given in **°C**, while **fan speed**
is given in percentage of **maximum** fan speed (0 - 100%).

Subsequent data points should be set to higher **temperatures** and higher
**rpm** values to achieve higher fan speeds with increasing temperature. The
last data point reflects critical temperature, in which the fans should run at
**full speed** (100%). Always set last point to **100%**.

If your cooler is big enough to obtain enough cooling at low CPU temperature
without spinning the fan, you can set speed of first point to **0%**, if
your cooler is small and can't give enough passive cooling, set **non zero**
fan speed even for your first point in curve.

Rough representation of temp/speed curve is given below:
```
     rpm

     / \
      |                            P5
rpm-5 |                            o
      |                           /
      |                          /
      |                     P4  /
rpm-4 |                        o
      |                      /
      |                P3  /
rpm-3 |                  o
      |                /
      |         P2   /
rpm-2 |            o
      |          /
      |  P1   /
rpm-1 |    o
      |
      +----------------------------------> Temp
           T1      T2    T3   T4   T5
```

</ul>


**4. Activation** &<br>
**5. Boot time control**

<ul>

After **temp/speed** profile has been setup, script will activate fan control,
and you will be asked to confirm if you want to enable it on boot time.
</ul>

<br>

### Setup process looks similar as shown below:

![setup process](doc/media/setup.gif)


# Status
To report current CPU/FAN status run:
```
cpu-fan status
```
this will result in output similar to this:


![cpu-fan status](doc/media/status.png)

**CPU temperature** is current CPU temp, **High temperature** is temperature at
which you should have **100%** fan speed. **Critical temperature** on the other
hand, is temperature at which your CPU will start to throttle down, to preserve
it's life :).

Bottom part is table representation of current **temp/speed** profile.

# Redefine temp/speed profile & enable/disable fan control

If you want to redefine **temp/speed** profile points, you have to run
```
sudo cpu-fan setup
```
You can skip detection of CPU fan controller. To enable/disable activation
of fan control at startup, run
```
sudo cpu-fan {enable|disable}
```

# Possible problems

When running
```
sudo cpu-fan setup
```
following problems can be encountered:

**lm-sensors not present**

<ul>

If **lm-sensors** tools are not installed on the system, **cpu-fan** will
refuse to continue with following message:

![lm-sensors not present](doc/media/no-lm-sensors.png)

you can proceed when you install **lm-sensor**.
</ul>

**proper chip not detected**

<ul>

If proper chip has not been detected by script, you will be given
following instructions:

![chip not present](doc/media/no-chip-present.png)
</ul>
