#Bucky

##Description

Given a 3D wireframe model in OBJ, STL, OFF, or OM format, Bucky generates 3D models for unique connectors at every vertex, as well as length for every edge.

![ring](https://github.com/wieden-kennedy/bucky/blob/master/support/cura/ring.jpg?raw=true)

###Compatibility
Bucky is compatible with, and tested on:

* OS X *(tested on 10.11)*
* Debian-based Linux *(tested on Ubuntu 16.04)*
* Fedora-based Linux *(tested on Fedora 23)*


##Installation

1. cURL the Bucky installer file, then run it!

    ```shell
    $ curl -O https://raw.githubusercontent.com/wieden-kennedy/bucky/master/install && bash install

    # NOTE: If you'd rather redirect cURL to bash with a pipe (`curl foobar | bash`),
    # just know that in doing so, you will bypass all prompts for consent (Bucky
    # will go hog wild and install whatever it wants/needs to install). Up to you.
    ```
    
Bucky will walk you through installing all of its dependencies, and compile and
install its own binaries into your system path. Once that's all done, you can start using it!

###(Re)Compiling Bucky's Dependent Executables
If for some reason you need to recompile the dependent bucky executable files,
you can do so super easily by re-running the install file using the appropriate
flag:

```shell
$ bucky -c
```

Optionally, if you are working with Bucky on OS X, you can open up the XCode
project and build the executables there. The XCode project is located at `/opt/bucky/src/openmesh/xcode`.

###Updating Bucky
If you'd like to do an in-place upgrade of Bucky, you can do so by running bucky
with the `-u` flag:

```shell
$ bucky -u
```
Running the above will pull the latest code from the `master` branch down to
your system.

###Removing Bucky
It's pretty easy to remove Bucky, but, be forewarned, you will not be able to do
so without some pretty passive-agressive efforts to deter you:

```shell
bucky -r
```
**Of Note**: Removing Bucky will not remove its dependencies, and will not
remove the folder of generated vertices (`~/Documents/__bucky__`).

##Using Bucky
Bucky comes with three object mesh models pre-installed, which can be found at
`/opt/bucky/support/mesh/`. These are a great place to start to see how Bucky
handles creating connector models. We will use the icosahedron model for this walkthrough.

1. To get started, run the following command from a terminal prompt:

   ```sh
   $ bucky /opt/bucky/support/mesh/icosahedron.obj
   ```

2. Bucky will create the connector models and stash the generated files under
   `~/Documents/__bucky__/generated-Y-m-dTH:M`, where the current date/time
   parts of the filepath are the actual time of completion. You can find the
   generated connector models under the subpath `stl/`.

3. Import the generated connector models into
   [Cura 15.04](https://ultimaker.com/en/cura-software/list), rotating them so
   that the sphere (center of the connector) and the side with the most
   connections sit on the printer bed.
   
   ###Important Note
   ```
   Currently, Bucky doesn't number the connector parts, so it is
   important to note which connectors (0, 1, 2...n) are placed on the printer
   bed where. 
   
   For example, if you are printing 8 connectors at a time, you may
   place `conn0.stl` through `conn3.stl` in the first row, and `conn4.stl`
   through `conn7.stl` in the second, just to keep them organized.
   
   We have plans to remedy this in the future so that each connector is labeled
   when printed.
   ```
![cura](https://github.com/wieden-kennedy/bucky/blob/master/support/cura/example.png?raw=true)

4. Load Cura profile `cura_profile.ini` from the generated folder using `File - Open Profile...`.

5. Save G-Code `File - Save GCode...` to an SD card, and print on your 3D printer.


e
