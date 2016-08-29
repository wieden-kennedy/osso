#osso

##Description

Given a 3D wireframe model in OBJ, STL, OFF, or OM format, osso generates 3D models for unique connectors at every vertex, as well as length for every edge.

![ring](https://github.com/wieden-kennedy/osso/blob/master/support/cura/ring.jpg?raw=true)

###Compatibility
osso is compatible with, and tested on:

* OS X *(tested on 10.11)*
* Debian-based Linux *(tested on Ubuntu 16.04)*
* Fedora-based Linux *(tested on Fedora 23)*


##Installation

1. cURL the osso installer file, then run it!

    ```shell
    $ curl -O https://raw.githubusercontent.com/wieden-kennedy/osso/master/install && bash install

    # NOTE: If you'd rather redirect cURL to bash with a pipe (`curl foobar | bash`),
    # just know that in doing so, you will bypass all prompts for consent (osso
    # will go hog wild and install whatever it wants/needs to install). Up to you.
    ```
    
osso will walk you through installing all of its dependencies, and compile and
install its own binaries into your system path. Once that's all done, you can start using it!

###(Re)Compiling osso's Dependent Executables
If for some reason you need to recompile the dependent osso executable files,
you can do so super easily by re-running the install file using the appropriate
flag:

```shell
$ osso -c
```

Optionally, if you are working with osso on OS X, you can open up the XCode
project and build the executables there. The XCode project is located at `/opt/osso/src/openmesh/xcode`.



##Using osso
osso comes with three object mesh models pre-installed, which can be found at
`/opt/osso/support/mesh/`. These are a great place to start to see how Bucky
handles creating connector models. We will use the icosahedron model for this walkthrough.

1. To get started, run the following command from a terminal prompt:

   ```sh
   $ osso /opt/osso/support/mesh/icosahedron.obj
   ```

   If you don't specify the model file as the first parameter, that's cool, just
   be sure to use the ```-m``` flag.
   
   ```sh
   $ osso -c -m /opt/osso/support/mesh/icosahedron.obj
   ```
  
2. By default, osso will create the connector models and stash the generated files under
   `~/Documents/__osso__/generated-{datetime_stamp}`, where `datetime_stamp` is
   the time of completion. You can find the generated connector models
   under the subpath `stl/`.
   
   If you would like to have osso output to a different directory in the
   `~/Documents/__osso__` directory, you can use the `-o` (lowercase) flag:
   
   ```sh
   $ osso /opt/osso/support/mesh/icosahedron -o my_rad_model
   ```
   
   Alternatively, if you want to put the folder somewhere else altogether, you
   can use the ```-O``` (uppercase) flag:
   
   ```sh
   $ osso /opt/osso/support/mesth/icosahedron -O /some/other/path/to/my_rad_model
   ```

3. Import the generated connector models into
   [Cura 15.04](https://ultimaker.com/en/cura-software/list), rotating them so
   that the sphere (center of the connector) and the side with the most
   connections sit on the printer bed.
   
   ###Important Note
   ```
   Currently, osso doesn't number the connector parts, so it is
   important to note which connectors (0, 1, 2...n) are placed on the printer
   bed where. 
   
   For example, if you are printing 8 connectors at a time, you may
   place `conn0.stl` through `conn3.stl` in the first row, and `conn4.stl`
   through `conn7.stl` in the second, just to keep them organized.
   
   We have plans to remedy this in the future so that each connector is labeled
   when printed.
   ```
![cura](https://github.com/wieden-kennedy/osso/blob/master/support/cura/example.png?raw=true)

4. Load Cura profile `cura_profile.ini` from the generated folder using `File - Open Profile...`.

5. Save G-Code `File - Save GCode...` to an SD card, and print on your 3D printer.


###Updating osso
If you'd like to do an in-place upgrade of osso, you can do so by running osso
with the `-u` flag:

```shell
$ osso -u
```
Running the above will pull the latest code from the `master` branch down to
your system.

###Removing osso
It's pretty easy to remove osso, but, be forewarned, you will not be able to do
so without some pretty passive-agressive efforts to deter you:

```shell
osso -r
```
**Of Note**: Removing osso will not remove its dependencies, and will not
remove the folder of generated vertices (`~/Documents/__osso__`).
