#pragma once

#include "ADKernelGrad.h"

/**
 * This calculates a modified coupled time derivative that multiplies the time derivative of a
 * coupled variable by a function of the variables and interface normal
 */

class ADSurfaceAnisotropy1 : public ADKernelGrad
{
public:
  static InputParameters validParams();
  ADSurfaceAnisotropy1(const InputParameters & parameters);


protected:
  virtual ADRealVectorValue precomputeQpResidual();

  const ADMaterialProperty<Real> & _L;
  const ADMaterialProperty<Real> & _eps;

};
