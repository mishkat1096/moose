//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

// MOOSE includes
#include "ADTimeKernelGrad.h"
#include "LevelSetVelocityInterface.h"

/**
 * Applies SUPG stabilization to the time derivative.
 */
class LevelSetTimeDerivativeSUPG : public LevelSetVelocityInterface<ADTimeKernelGrad>
{
public:
  static InputParameters validParams();

  LevelSetTimeDerivativeSUPG(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  using LevelSetVelocityInterface<ADTimeKernelGrad>::computeQpVelocity;
  using LevelSetVelocityInterface<ADTimeKernelGrad>::_velocity;
};
