#!/bin/bash
#SBATCH -N 1
#SBATCH -n 32
#SBATCH -p rc
#SBATCH -w d0003

# Setting up the environment
source env_OpenFOAM-12.sh

# Creating the src directory for the installed application
mkdir -p $SOFTWARE_DIRECTORY/src

# Installing $SOFTWARE_NAME/$SOFTWARE_VERSION
# Intalling UCX
cd $SOFTWARE_DIRECTORY/src
wget https://github.com/openucx/ucx/releases/download/v1.16.0/ucx-1.16.0.tar.gz
tar -xvf ucx-1.16.0.tar.gz
cd ucx-1.16.0/
./contrib/configure-release --prefix=$SOFTWARE_DIRECTORY
make
make install

# Installing OpenMPI
cd $SOFTWARE_DIRECTORY/src
wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz
tar -xvf openmpi-4.1.6.tar.gz
cd openmpi-4.1.6
./configure --prefix=$SOFTWARE_DIRECTORY/ --with-ucx=$SOFTWARE_DIRECTORY --with-ucx-libdir=$SOFTWARE_DIRECTORY/lib --with-pmix
make -j all
make install

# Installing FLEX
cd $SOFTWARE_DIRECTORY/src
wget https://github.com/westes/flex/releases/download/flex-2.5.39/flex-2.5.39.tar.gz
tar -xvf flex-2.5.39.tar.gz
cd flex-2.5.39
./configure --prefix=$SOFTWARE_DIRECTORY
make
make install

# Installing OpenFOAM-12
cd $SOFTWARE_DIRECTORY/src
git clone https://github.com/OpenFOAM/OpenFOAM-12.git
git clone https://github.com/OpenFOAM/ThirdParty-12.git
source $SOFTWARE_DIRECTORY/src/OpenFOAM-12/etc/bashrc
cd $SOFTWARE_DIRECTORY/src/ThirdParty-12
./Allwmake
cd $SOFTWARE_DIRECTORY/src/OpenFOAM-12
./Allwmake -j

# Creating modulefile
touch $SOFTWARE_VERSION
echo "#%Module" >> $SOFTWARE_VERSION
echo "module-whatis	 \"Loads $SOFTWARE_NAME/$SOFTWARE_VERSION module." >> $SOFTWARE_VERSION
echo "" >> $SOFTWARE_VERSION
echo "This module was build on $(date)" >> $SOFTWARE_VERSION
echo "" >> $SOFTWARE_VERSION
echo "OpenFOAM (https://cmake.org/) is Computational Fluid Dynamics (CFD) program." >> $SOFTWARE_VERSION
echo "" >> $SOFTWARE_VERSION
echo "The script used to build this module can be found here: $GITHUB_URL" >> $SOFTWARE_VERSION
echo "" >> $SOFTWARE_VERSION
echo "To load the module, type:" >> $SOFTWARE_VERSION
echo "module load $SOFTWARE_NAME/$SOFTWARE_VERSION" >> $SOFTWARE_VERSION
echo "" >> $SOFTWARE_VERSION
echo "Please run: source \"$SOFTWARE_DIRECTORY/src/OpenFOAM-12/etc/bashrc" >> $SOFTWARE_VERSION
echo "\"" >> $SOFTWARE_VERSION
echo "" >> $SOFTWARE_VERSION
echo "conflict	 $SOFTWARE_NAME" >> $SOFTWARE_VERSION
echo "prepend-path	 PATH $SOFTWARE_DIRECTORY/bin" >> $SOFTWARE_VERSION
echo "prepend-path       PATH $SOFTWARE_DIRECTORY/OpenFOAM-12/bin" >> $SOFTWARE_VERSION
echo "prepend-path       PATH $SOFTWARE_DIRECTORY/OpenFOAM-12/bin/tools" >> $SOFTWARE_VERSION
echo "prepend-path       LIBRARY_PATH $SOFTWARE_DIRECTORY/lib" >> $SOFTWARE_VERSION
echo "prepend-path       LD_LIBRARY_PATH $SOFTWARE_DIRECTORY/lib" >> $SOFTWARE_VERSION
echo "prepend-path       CPATH $SOFTWARE_DIRECTORY/include" >> $SOFTWARE_VERSION

# Moving modulefile
mkdir -p $CLUSTER_DIRECTORY/modulefiles/$SOFTWARE_NAME
cp $SOFTWARE_VERSION $CLUSTER_DIRECTORY/modulefiles/$SOFTWARE_NAME/$SOFTWARE_VERSION
