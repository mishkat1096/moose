//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Material.h"


// Forward Declarations
class VelocityDependentk;
//class MooseVariableScalar;

template <>
InputParameters validParams<VelocityDependentk>();

/**
 * Material to compute the angular orientation of order parameter interfaces.
 * See R. Kobayashi, Physica D, 63, 410-423 (1993), final (non-numbered) equation
 * on p. 412. doi:10.1016/0167-2789(93)90120-P
 */
class VelocityDependentk : public Material
{
public:
  VelocityDependentk(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  const Real _Vd;
  Real _model;
  Real _A;
  Real _Ke;
  Real _scale;


  MaterialProperty<Real> & _vel;
  MaterialProperty<Real> & _k;

//  SystemBase & _sys;

  //THREAD_ID _tid;
  //MooseVariableScalar & _var;
   const  VariableValue & _w;
   const VariableValue & _w_dot;
   const VariableGradient & _grad_w;
};
