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
  `cd ~/projects
   ./moose/scripts/stork.sh YourAppName`

## Enable modules:
  - Modify the section of ~/projects/your_app_name/Makefile `ALL_MODULES` to `Yes`

## Running input files:
  `./YourAppName-opt -t ~/projects/moose/inputfiles/Choose_an_inputfiles.i`
