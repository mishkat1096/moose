//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "GeneralPostprocessor.h"
#include "Coupleable.h"

class FindVariableValueOnLine;

template <>
InputParameters validParams<FindVariableValueOnLine>();

/**
 * Computes the difference between two postprocessors
 *
 * result = value1 - value2
 */
class FindVariableValueOnLine : public GeneralPostprocessor,
                                public Coupleable
{
public:
  static InputParameters validParams();

  FindVariableValueOnLine(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual PostprocessorValue getValue() override;

protected:
  Real getValueAtPoint(const Point & p);
  const PostprocessorValue & _location;
  const Point _start_point;
  const Point _end_point;
  Real _value;
  Real _length;
  MooseVariable & _coupled_var;
  MooseMesh & _mesh;
  std::vector<Point> _point_vec;
  std::unique_ptr<PointLocatorBase> _pl;

};
