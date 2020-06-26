#include "ADSurfaceAnisotropy1.h"

registerMooseObject("PhaseFieldApp", ADSurfaceAnisotropy1);

InputParameters
ADSurfaceAnisotropy1::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription("Anisotropic surfae energy term");
  params.addParam<MaterialPropertyName>("mob_name", "L", "Mobility used in kernel");
  params.addParam<MaterialPropertyName>("eps_name", "eps", "The anisotropic interface parameter");
  params.addParam<MaterialPropertyName>("deps_name", "deps", "The derivative of the anisotropic interface paramter w.r.t angle");

  return params;
}

ADSurfaceAnisotropy1:: ADSurfaceAnisotropy1(const InputParameters & parameters)
:ADKernelGrad(parameters),
_L(getADMaterialProperty<Real>("mob_name")),
_eps(getADMaterialProperty<Real>("eps_name"))

{

}

ADRealVectorValue
ADSurfaceAnisotropy1::precomputeQpResidual()
{
  return _eps[_qp] * _eps[_qp] * _L[_qp] * _grad_u[_qp];
}
