Detailed installation instruction can be found in https://mooseframework.inl.gov/getting_started/installation/index.html

* Linux Users:

  `curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
   bash Miniconda3-latest-Linux-x86_64.sh -b -p ~/miniconda3`

* Macintosh Users:

  `curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
   bash Miniconda3-latest-MacOSX-x86_64.sh -b -p ~/miniconda3`

- Export PATH, so that it may be used:

  `export PATH=$HOME/miniconda3/bin:$PATH`

- Configure anaconda:

  `conda config --add channels conda-forge
   conda config --add channels idaholab`

- Install the moose-libmesh and moose-tools package from mooseframework.org, and name your environment 'moose':

  `conda create --name moose moose-libmesh moose-tools`

- Activate the moose environment (do this for any new terminal opened):

  `conda activate moose`

- Installing MOOSE:

  `mkdir ~/projects`
  
  `cd ~/projects`
   
  `git clone https://github.com/mishkat1096/moose.git`
   
  `cd moose`
   
  `git checkout PhaseField`

## Create Application:
Application can be created with any name. For example, here Phase Field is used. The created folder and the executable both be of the same name (PhaseField). So, the stork.sh creates the executable under the folder with same name, `./moose/scripts/stork.sh PhaseField` Creats a folder PhaseField containing the executable PhaseField-opt

  `cd ~/projects
   ./moose/scripts/stork.sh PhaseField`

## Enable modules:
  - Modify the section of ~/projects/PhaseField/Makefile set `ALL_MODULES` to `Yes`.
  
  And then perform
  
  `make -j4`
  
  to make the `PahseField-opt` executable.

## Running input files:
The inputfiles directory contains all the input files. There are sub-directories for different alloys. For example, to run an input file form Si-As alloy:

  `./PhaseField-opt -i ~/projects/moose/inputfiles/Si-AS/Si-As_nd_e30_v5_A.01.i`

## Visualization
MOOSE outputs in _exodus_ format. For example, after running the above input file `Si-As_nd_e30_v5_A.01` the output will be `Si-As_nd_e30_v5_A.01_exodus.e`.
For each particular timesteps (specified in the input file) the output looks like `Si-As_nd_e30_v5_A.01_exodus.e-s002` and so on.

- For visualization, we used open source visualization software _paraview_ (can be downloaded from https://www.paraview.org/download/).

To visualize just load by going to `File` then `Open` then select `Si-As_nd_e30_v5_A.01_exodus.e` to _paraview_ for visualization.

- MOOSE has a built in visualization tool named _peacock_.
To add Peacock to PATH: assuming that $ MOOSE_DIR is the location of git clone, navigate to the $MOOSE_DIR/python/peacock directory, and type: pwd. Whatever is printed out is the path to Peacock. Next, add the following to the end of your ~/bash_profile (Macintosh) or ~/.bashrc (Ubuntu) file:

`export PATH=pwd:$PATH`

The following examples assuming Peacock was added to PATH. General usage is as follows:

`cd ~/projects/<your application directory>
peacock`

Peacock will search upwards from the current directory, and attempt to find the application's executable. Syntax is gathered, as presented with input syntax specific to the application.

`cd ~/projects/trunk/<your application directory>/<your test directory>
peacock -i your_input_file.i`
