//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADKernelGrad.h"

/**
 * This calculates a modified coupled time derivative that multiplies the time derivative of a
 * coupled variable by a function of the variables and interface normal
 */

class ADAntitrappingCurrent : public ADKernelGrad
{
public:
  static InputParameters validParams();
  ADAntitrappingCurrent(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual();

  const ADMaterialProperty<Real> & _F;
  const ADVariableValue & _v_dot;
  const ADVariableGradient & _grad_v;

};
