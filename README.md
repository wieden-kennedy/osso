# OpenVertex

#### Description

Given a 3D wireframe model in OBJ, STL, OFF, or OM format, generate 3D models for unique connectors at every vertex, as well as length for every edge.

![ring](https://github.com/needybot/open-vertex/blob/master/cura/ring.jpg?raw=true)

#### Installation

1. Install [OpenSCAD](http://www.openscad.org/) Software.
2. Install [OpenMesh](http://www.openmesh.org/) and [SolidPython](https://github.com/SolidCode/SolidPython) with the following command,

	```sh
	$ brew install open-mesh rapidjson
	$ pip install solidpython
	$ ln -s /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD openscad
	```

3. (Optional) Compile `openmesh/calc_edge_lengths.cpp` and `openmesh/calc_edge_lengths.cpp` to generate executables and put them in `scripts` folder.
4. (Optional) Download Needybot [mesh file](https://github.com/needybot/open-vertex/blob/master/mesh/NB_B2_v019d_connector.obj) and generated [connector models](https://drive.google.com/open?id=0B2xef5QHbuSmQTlFTlYtUEhXTVk).

#### Usage

1. Generate connector models with the following commands, find output models at `scripts/stl/conn*.stl`. (Skip this if you have already downloaded the connector models in Step 4 of Installation)

	```sh
	$ cd scripts
	$ ./run.sh ../mesh/icosahedron.obj
	```

2. Import connector models in slicer software [Cura 15.04](https://ultimaker.com/en/cura-software/list), rotate the models so that the sphere and the side with the most number of connections sit on the platform. **Important: Remember the positions of model placement**. For example, if you are printing 8 pieces of connectors at a time, place `conn0.stl` to `conn3.stl` in the first row, and `conn4.stl` to `conn7.stl` in the second row is a good solution. **It's also easier to remove the connectors as one piece if they are placed near each other**, since the raft (base layers) of each connector will be connected together.  
3. Load Cura profile `cura/profile.ini` using `File - Open Profile...`
4. Generate G-Code `File - Save GCode...` to SD card and print

![cura](https://github.com/needybot/open-vertex/blob/master/cura/example.png?raw=true)
