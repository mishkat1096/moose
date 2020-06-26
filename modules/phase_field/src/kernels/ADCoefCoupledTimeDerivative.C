//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADCoefCoupledTimeDerivative.h"

registerMooseObject("PhaseFieldApp", ADCoefCoupledTimeDerivative);

InputParameters
ADCoefCoupledTimeDerivative::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription("Time derivative Kernel that acts on a coupled variable. Weak form: "
                             "$(\\psi_i, \\frac{\\partial v_h}{\\partial t})$.");
  params.addRequiredCoupledVar("v", "Coupled variable");
  params.addRequiredParam<MaterialPropertyName>("coef", "Coefficient");

  return params;

}


ADCoefCoupledTimeDerivative:: ADCoefCoupledTimeDerivative(const InputParameters & parameters)
:ADKernelValue(parameters),
 _v_dot(adCoupledDot("v")),
_coef(getADMaterialProperty<Real>("coef"))
{
}


ADReal
ADCoefCoupledTimeDerivative::precomputeQpResidual()
{
  return _v_dot[_qp] * _coef[_qp];
}
