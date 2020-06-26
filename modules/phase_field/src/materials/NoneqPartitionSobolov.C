//* This file is part of the MOOSE frameuork
//* https://uuu.mooseframeuork.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://uuu.gnu.org/licenses/lgpl-2.1.html

#include "NoneqPartitionSobolov.h"


registerMooseObject("PhaseFieldApp", NoneqPartitionSobolov);

template <>
InputParameters
validParams<NoneqPartitionSobolov>()
{
  InputParameters params = validParams<Material>();
  //params.addRequiredParam<NonlinearVariableName>(
    //  "variable", "The name of the variable that this kernel operates on");
  params.addParam<Real>(
      "Vd", "Diffusion Velocity");
  params.addParam<Real>("Ke","Equillibrium Partitioning Coefficient");
  params.addRequiredCoupledVar("w", "Order parameter defining the solid phase");
  return params;
}

NoneqPartitionSobolov::NoneqPartitionSobolov(const InputParameters & parameters)
  : Material(parameters),
    _Vd(getParam<Real>("Vd")),
    _Ke(getParam<Real>("Ke")),
    _vel(declareProperty<Real>("vel")),
    _k(declareProperty<Real>("k")),
  //  _sys(*getCheckedPointerParam<SystemBase *>("_sys")),
  //  _tid(parameters.get<THREAD_ID>("_tid")),
  //  _var(_sys.getScalarVariable(_tid, parameters.get<NonlinearVariableName>("variable"))),
    //_u(_var.sln()),
    //_u_old(_var.slnOld()),
    _w(coupledValue("w")),
    _w_old(coupledValueOld("w")),
    _grad_w(coupledGradient("w"))
{
  // this currently only uorks in 2D simulations
}

void
NoneqPartitionSobolov::computeQpProperties()
{

  const Real nsq = _grad_w[_qp].norm_sq();
  Real n;
  if (nsq == 0)
  {
    _vel[_qp] = 0;
    n = _Ke;
  }
  if (nsq != 0)
  {
    _vel[_qp] = (_w[_qp] - _w_old[_qp])/( nsq * _dt );

  if ( _vel[_qp] < _Vd)
  {

    n = (_Ke * ((1 - (_vel[_qp]/_Vd) * (_vel[_qp]/_Vd)) + (_vel[_qp]/_Vd)))/ ((1 - (_vel[_qp]/_Vd) * (_vel[_qp]/_Vd)) + (_vel[_qp]/_Vd)) ;

  }
  if (_vel[_qp] >= _Vd )
  {
    n = 0.99;
  }

  }
  _k[_qp] = n;

}
