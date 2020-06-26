#include "ADSurfaceAnisotropy.h"

registerMooseObject("PhaseFieldApp", ADSurfaceAnisotropy);

InputParameters
ADSurfaceAnisotropy::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription("Anisotropic surfae energy term");
  params.addParam<MaterialPropertyName>("mob_name", "L", "Mobility used in kernel");
  params.addParam<MaterialPropertyName>("eps_name", "eps", "The anisotropic interface parameter");
  params.addParam<MaterialPropertyName>("deps_name", "deps", "The derivative of the anisotropic interface paramter w.r.t angle");

  return params;
}

ADSurfaceAnisotropy:: ADSurfaceAnisotropy(const InputParameters & parameters)
:ADKernelGrad(parameters),
_L(getADMaterialProperty<Real>("mob_name")),
_eps(getADMaterialProperty<Real>("eps_name")),
_deps(getADMaterialProperty<Real>("deps_name"))
{

}

ADRealVectorValue
ADSurfaceAnisotropy::precomputeQpResidual()
{
  const ADRealVectorValue v(-_grad_u[_qp](1), _grad_u[_qp](0), 0);

  return _eps[_qp] * _deps[_qp] * _L[_qp] * v;
}
