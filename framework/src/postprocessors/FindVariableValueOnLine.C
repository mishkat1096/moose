//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FindVariableValueOnLine.h"
#include "MooseMesh.h"
#include "MooseUtils.h"
#include "MooseVariable.h"

registerMooseObject("MooseApp", FindVariableValueOnLine);

defineLegacyParams(FindVariableValueOnLine);

InputParameters
FindVariableValueOnLine::validParams()
{
  InputParameters params = GeneralPostprocessor::validParams();
  params.addRequiredParam<PostprocessorName>("location", "location");
  params.addCoupledVar("v", "Variable to inspect");
  params.addParam<Point>("start_point", "Start point of the sampling line.");
  params.addParam<Point>("end_point", "End point of the sampling line.");

  return params;
}

FindVariableValueOnLine::FindVariableValueOnLine(const InputParameters & parameters)
  : GeneralPostprocessor(parameters),
    Coupleable(this, false),
   _location(getPostprocessorValue("location")),
   _start_point(getParam<Point>("start_point")),
   _end_point(getParam<Point>("end_point")),
   _value(0),
   _length((_end_point - _start_point).norm()),
   _coupled_var(*getVar("v", 0)),
   _mesh(_subproblem.mesh()),
   _point_vec(1)
{
}

void
FindVariableValueOnLine::initialize()
{
  _pl = _mesh.getPointLocator();
  _pl->enable_out_of_mesh_mode();
}

void
FindVariableValueOnLine::execute()
{
  Real m = 0; 
 
  m = _location/_length ;

  Point p = m * (_end_point - _start_point) + _start_point;

   _value = getValueAtPoint(p);

}

Real
FindVariableValueOnLine::getValueAtPoint(const Point & p)
{
  const Elem * elem = (*_pl)(p);

  processor_id_type elem_proc_id = elem ? elem->processor_id() : DofObject::invalid_processor_id;
  _communicator.min(elem_proc_id);
  Real quantity = 0;

  if (elem)
  {
    if (elem->processor_id() == processor_id())
    {
      // element is local
       _point_vec[0] = p;
       _subproblem.reinitElemPhys(elem, _point_vec, 0);
       quantity = _coupled_var.sln()[0];
    }
  }

  // broadcast value
  _communicator.broadcast(quantity, elem_proc_id);
  return quantity;
}

PostprocessorValue
FindVariableValueOnLine::getValue()
{

  return _value;
}
