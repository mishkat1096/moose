//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADAntitrappingCurrent.h"

registerMooseObject("PhaseFieldApp", ADAntitrappingCurrent);

InputParameters
ADAntitrappingCurrent::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription("AntitrappingCurrent");
  params.addParam<MaterialPropertyName>("f_name", "F", "Mobility used in kernel");
  params.addRequiredCoupledVar("v","Coupled Variable");

  return params;

}

ADAntitrappingCurrent::ADAntitrappingCurrent(const InputParameters & parameters)
  : ADKernelGrad(parameters),
  _F(getADMaterialProperty<Real>("f_name")),
  _v_dot(adCoupledDot("v")),
  _grad_v(adCoupledGradient("v"))
{
}

ADRealVectorValue
ADAntitrappingCurrent::precomputeQpResidual()
{
  const ADReal norm_sq = _grad_v[_qp].norm_sq();
  if (norm_sq < libMesh::TOLERANCE)
    return 0.0;

  return _F[_qp] * _v_dot[_qp] * _grad_v[_qp] / std::sqrt(norm_sq);
}
