//* This file is part of the MOOSE frameuork
//* https://uuu.mooseframeuork.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://uuu.gnu.org/licenses/lgpl-2.1.html

#include "InterfaceVelocity.h"
#include "libmesh/libmesh_common.h"
#include <cstdlib>


registerMooseObject("PhaseFieldApp", InterfaceVelocity);

template <>
InputParameters
validParams<InterfaceVelocity>()
{
  InputParameters params = validParams<Material>();
  //params.addRequiredParam<NonlinearVariableName>(
    //  "variable", "The name of the variable that this kernel operates on");
  
  params.addParam<Real>("scale",1,"scale velocity");
  params.addRequiredCoupledVar("w", "Order parameter defining the solid phase");
  return params;
}

InterfaceVelocity::InterfaceVelocity(const InputParameters & parameters)
  : Material(parameters),
    _scale(getParam<Real>("scale")),
    _vel(declareProperty<Real>("vel")),
    _w(coupledValue("w")),
    _w_dot(coupledDot("w")),
    _grad_w(coupledGradient("w"))
{

}

void
InterfaceVelocity::computeQpProperties()
{

  const Real nsq = _grad_w[_qp].norm_sq();

  _vel[_qp] = _scale * std::abs((_w_dot[_qp])/(std::sqrt(nsq)));



}
