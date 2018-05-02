//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef SODIUMPROPERTIESTEST_H
#define SODIUMPROPERTIESTEST_H

#include "MooseObjectUnitTest.h"
#include "SodiumProperties.h"

class SodiumPropertiesTest : public MooseObjectUnitTest
{
public:
  SodiumPropertiesTest() : MooseObjectUnitTest("MooseUnitApp")
  {
    registerObjects(_factory);
    buildObjects();
  }

protected:
  void registerObjects(Factory & factory) { registerUserObject(SodiumProperties); }

  void buildObjects()
  {
    InputParameters uo_pars = _factory.getValidParams("SodiumProperties");
    _fe_problem->addUserObject("SodiumProperties", "fp", uo_pars);
    _fp = &_fe_problem->getUserObject<SodiumProperties>("fp");
  }

  const SodiumProperties * _fp;
};

#endif // SODIUMPROPERTIESTEST_H
