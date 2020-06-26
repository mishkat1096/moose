//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADKernelValue.h"

// Forward Declaratio

/**
 * This calculates the time derivative for a coupled variable multiplied by a
 * scalar coefficient
 */
class ADCoefCoupledTimeDerivative : public ADKernelValue

{
public:
  static InputParameters validParams();
  ADCoefCoupledTimeDerivative(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual();

  const ADVariableValue & _v_dot;

  const ADMaterialProperty<Real> & _coef;

};
