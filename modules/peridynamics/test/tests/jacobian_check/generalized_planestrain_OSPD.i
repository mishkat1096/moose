[GlobalParams]
  displacements = 'disp_x disp_y'
  scalar_out_of_plane_strain = scalar_strain_zz
  full_jacobian = true
[]

[Mesh]
  type = PeridynamicsMesh
  horizon_number = 3

  [./gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 4
    ny = 4
  [../]
  [./gpd]
    type = MeshGeneratorPD
    input = gmg
    retain_fe_mesh = false
  [../]
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]

  [./scalar_strain_zz]
    order = FIRST
    family = SCALAR
  [../]
[]

[AuxVariables]
  [./stress_zz]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Modules/Peridynamics/Mechanics]
  [./Master]
    [./all]
      formulation = ORDINARY_STATE
    [../]
  [../]
  [./GeneralizedPlaneStrain]
    [./all]
      formulation = ORDINARY_STATE
      out_of_plane_stress_variable = stress_zz
    [../]
  [../]
[]

[AuxKernels]
  [./stress_zz]
    type = NodalRankTwoPD
    variable = stress_zz

    poissons_ratio = 0.3
    youngs_modulus = 1e6

    rank_two_tensor = stress
    output_type = component
    index_i = 2
    index_j = 2
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    poissons_ratio = 0.3
    youngs_modulus = 1e6
  [../]

  [./force_density]
    type = ComputeSmallStrainConstantHorizonMaterialOSPD
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -snes_type'
    petsc_options_value = 'bcgs bjacobi test'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 1
  dt = 1
  num_steps = 1
[]
