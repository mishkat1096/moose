//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ConstWeightEulerAngleProvider.h"

#include <fstream>

registerMooseObject("TensorMechanicsApp", ConstWeightEulerAngleProvider);

template <>
InputParameters
validParams<ConstWeightEulerAngleProvider>()
{
  InputParameters params = validParams<EulerAngleProvider>();
  params.addClassDescription("Read Euler angle data from a file and provide it to other objects.");
  params.addRequiredParam<FileName>("file_name", "Euler angle data file name");
  return params;
}

ConstWeightEulerAngleProvider::ConstWeightEulerAngleProvider(const InputParameters & params)
  : EulerAngleProvider(params), _file_name(getParam<FileName>("file_name"))
{
  readFile();
}

unsigned int
ConstWeightEulerAngleProvider::getGrainNum() const
{
  return _angles.size();
}

const EulerAngles &
ConstWeightEulerAngleProvider::getEulerAngles(unsigned int i) const
{
  mooseAssert(i < getGrainNum(), "Requesting Euler angles for an invalid grain id");
  return _angles[i];
}

void
ConstWeightEulerAngleProvider::readFile()
{
  // Read in Euler angles from _file_name
  std::ifstream inFile(_file_name.c_str());
  if (!inFile)
    mooseError("Can't open ", _file_name);

  // Loop over grains
  EulerAngles a;
  while (inFile >> a.phi1 >> a.Phi >> a.phi2)
    _angles.push_back(EulerAngles(a));
}
