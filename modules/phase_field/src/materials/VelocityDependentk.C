//* This file is part of the MOOSE frameuork
//* https://uuu.mooseframeuork.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://uuu.gnu.org/licenses/lgpl-2.1.html

#include "VelocityDependentk.h"
#include "libmesh/libmesh_common.h"
#include <cstdlib>


registerMooseObject("PhaseFieldApp", VelocityDependentk);

template <>
InputParameters
validParams<VelocityDependentk>()
{
  InputParameters params = validParams<Material>();
  //params.addRequiredParam<NonlinearVariableName>(
    //  "variable", "The name of the variable that this kernel operates on");
  params.addParam<Real>(
      "Vd",2.6e6, "Diffusion Velocity");
  params.addParam<Real>("Ke","Equillibrium Partitioning Coefficient");
  params.addParam<Real>("A",2.7e-6,"Coefficient for jackson model");
  params.addParam<Real>("model",3,"Which model to use 0:jackson, 1: analytical, 2: Aziz");
  params.addParam<Real>("scale",1,"scale velocity");
  params.addRequiredCoupledVar("w", "Order parameter defining the solid phase");
  return params;
}

VelocityDependentk::VelocityDependentk(const InputParameters & parameters)
  : Material(parameters),
    _Vd(getParam<Real>("Vd")),
    _model(getParam<Real>("model")),
    _A(getParam<Real>("A")),
    _Ke(getParam<Real>("Ke")),
    _scale(getParam<Real>("scale")),
    _vel(declareProperty<Real>("vel")),
    _k(declareProperty<Real>("k")),
    _w(coupledValue("w")),
    _w_dot(coupledDot("w")),
    _grad_w(coupledGradient("w"))
{

}

void
VelocityDependentk::computeQpProperties()
{

  const Real nsq = _grad_w[_qp].norm_sq();
  
  _vel[_qp] = _scale * std::abs((_w_dot[_qp])/(std::sqrt(nsq)));

  if (nsq == 0)
  {
    _vel[_qp] = 0;
    _k[_qp] = _Ke;
  }
  if (nsq != 0)
{

  if (_model == 1)
  {
  if ( _vel[_qp] < _Vd)
  {

    _k[_qp] = (_Ke * (1 - ((_vel[_qp]/_Vd) * (_vel[_qp]/_Vd)) + (_vel[_qp]/_Vd)))/ (1 - ((_vel[_qp]/_Vd) * (_vel[_qp]/_Vd)) + (_vel[_qp]/_Vd)) ;

  }
  if (_vel[_qp] >= _Vd )
  {
    _k[_qp] = 1;
  }
  }
  if (_model == 2)
  {
     _k[_qp] = (_Ke + (_vel[_qp]/_Vd))/(1 + (_vel[_qp]/_Vd));
  }
  else
  {
    _k[_qp] = pow(_Ke,(1/(1 + _A*_vel[_qp])));
  }
}


}
