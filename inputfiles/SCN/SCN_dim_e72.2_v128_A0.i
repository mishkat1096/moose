[Mesh]

  type = GeneratedMesh

  dim = 2

  ymin = -300

  xmin = 0

  xmax = 180

  ymax = 0

  nx = 20

  ny = 36

  uniform_refine = 3

[]

[Variables]

  [./phi]

  [./InitialCondition]

     #type = SmoothSuperellipsoidIC

      type = SmoothCircleIC

      variable = phi

      x1 = 90

      y1 = -300

   #   a = 1

   #   b = 2

   #   n = 2

      radius = 3

      invalue = 1

      outvalue = -1

      int_width = 2

    [../]

  [../]

  [./U]

     initial_condition = -1

  [../]

[]

[AuxVariables]

  [./f]

    order = CONSTANT

    family = MONOMIAL

  [../]

[]

#[UserObjects]

#  [./normal_masked_noise]

#    type = ConservedMaskedNormalNoise

#    mask = mask_prop

#  [../]

#[]

[Kernels]

  [./dUdt]

    type = TimeDerivative

    variable = U

  [../]

  [./Udiffusion]

    type = MatDiffusion

    variable = U

    diffusivity = D

    args = phi

  [../]

  #[./conserved_langevin]

#    type = ConservedLangevinNoise

#   amplitude = 3e-9

#   variable = U

#    noise = normal_masked_noise
#  []

  [./Ucoupledphi]

    type = CoupledSusceptibilityTimeDerivative

    variable = U

    v = phi

    f_name = Coef

    args = 'phi'

  [../]

  [./Anti_trapping]

    type = AntitrappingCurrent

    variable = U

    v = phi

    args = phi

    f_name = Antitrapping

  [../]


  [./dphidt]

    type = TimeDerivative

    variable = phi

  [../]

  [./phibulk]

    type = AllenCahn

    variable = phi

    f_name = f_chem

    mob_name = L

    args = 'U'

  [../]

  [./phi_surfaceanisotropy1]

    type = ACInterfaceKobayashi

    variable = phi

    eps_name = eps

    mob_name = L

  [../]

  [./phi_surfaceanisotropy]

    type = ACInterfaceKobayashi2

    variable = phi

    eps_name = eps

    mob_name = L

  [../]

[]

[Functions]

  [./y]

    type = ParsedFunction

    value = 'y'

  [../]

[]


[Materials]

  [./consts]

    type = GenericConstantMaterial

    prop_names  = 'Dl a1 a2 e G d pv m ci k'

    prop_values = '1000 .8839 .6267 72.2 .014 .013 128 20 .1 0.3'

  [../]

  [./time]

    type = TimeStepMaterial

    prop_time = time

  [../]

  [./y]

    type = GenericFunctionMaterial

    prop_names = y

    prop_values = y

  [../]

  #[./mask_material]

  #  type = ParsedMaterial

  #  f_name = 'mask_prop'

  #  args = 'U phi '

  #  material_property_names = 'Dl k dt'

  #  function = '2 * (Dl/dt) * ((1-phi)/2) * (1 + (1-k)*U)'

# [../]

  [./free_energy]

    type = DerivativeParsedMaterial

    f_name = f_chem

    args = 'phi U'

    material_property_names = 'y time pv lt a1 e'

    function = 'vp:= y - pv * time ; -0.5*phi^2 + 0.25*phi^4 + a1 * e * phi *(1-2/3*phi^2+0.2*phi^4)*( U + vp/lt )'

    outputs = exodus

  [../]

  #[./k]

  #   type = NoneqPartitionSobolov

  #   Vd = 2.6e6

  #   Ke = .3

  #   w = phi

  #[../]


  [./Anti_current]

    type = DerivativeParsedMaterial

   args = 'U phi'

   f_name = Antitrapping

    material_property_names = 'e d k'

    function = 'W:=e*d; 2*.35* W *( 1 + (1-k) * U )/ ((1+k) - (1-k)*phi)'

    outputs = exodus

  [../]

  [./W]

    type = InterfaceOrientationMaterial

    op = phi

    mode_number = 4

    anisotropy_strength = -0.007

    eps_bar = .94

    reference_angle = 0

  [../]

 [./Mobility]

    type = DerivativeParsedMaterial

    f_name = L

    material_property_names = 'a1 a2 e d Dl eps y pv time k lt '

    function = 'tau:= a1* a2 * e *((d*e)^2)/Dl; 1/ (tau* (eps/(e*d)) * (eps/(e*d)) * (1-(1-k) * (y - pv * time)/lt))'

    outputs = exodus

  [../]

  [./kappa]

    type = ParsedMaterial

    f_name = kappa

    material_property_names = 'eps'

    function = 'eps*eps'

  [../]

 [./epx]

    type = ParsedMaterial

    f_name = epx

    material_property_names = 'eps  '

    function = 'eps'

    outputs = exodus

  [../]


  [./til_D]

    type = DerivativeParsedMaterial

    f_name = D

    args = 'phi'

    material_property_names = 'Dl k'

    function = 'Dl * (1- phi)/ ((1+k) - (1-k)*phi)'

    outputs = exodus

  [../]

  #[./d]

  #  type = DerivativeParsedMaterial

  #  f_name = d

  #  material_property_names = 'W do eps'

  #  function = 'do*(1 - 15*(eps - 1))'

  #  outputs = exodus

  #[../]

  [./Lt]

    type = ParsedMaterial

    f_name = lt

    material_property_names = 'm ci k G'

    function = 'm * ci * (1-k)/ (k * G)'

    outputs = exodus

  [../]


  [./Coef]

    type = DerivativeParsedMaterial

    f_name = Coef

    args = 'U phi'

    material_property_names = 'k'

    function = '-(1+(1-k)*U) / ((1+k) - (1-k)*phi)'

    outputs = exodus

  [../]

[]

[BCs]

  [./Neumann_Bc]

    type = ADNeumannBC

    variable = 'phi'

    boundary = 'top bottom'

    value = 0

  [../]

  [./Neumann_BcU]

   type = ADNeumannBC

   variable = 'U'

   boundary = 'top bottom'

    value = 0

  [../]

  [./Periodic]

   [./y]

     variable = 'U phi'

     primary = left

     secondary = right

     translation = '180 0 0'

   [../]

 [../]

[]


[Postprocessors]

  [./memory]

    type = MemoryUsage

    mem_type = physical_memory

    report_peak_value = true

    execute_on = 'LINEAR NONLINEAR TIMESTEP_END'

  [../]

  [./free_energy]

    type = ElementIntegralVariablePostprocessor

    variable = f

    execute_on = 'INITIAL TIMESTEP_END'

  [../]

  [./tip_pos]

    type = FindValueOnLine

    start_point = '90 -300 0'

    end_point = '90 0 0'

    v = phi

    target = 0

    tol = 1e-6

    execute_on = 'INITIAL TIMESTEP_END'

  [../]

  #[./tip_pos1]

#    type = FindValueOnLine
#
#    start_point = '0 -400 0'

#    end_point = '400 -400 0'

#    v = phi

#    target = 0

#    tol = 1e-6

#    execute_on = 'INITIAL TIMESTEP_END'

#  [../]


[]



[Preconditioning]

  [./SMP]

    type = SMP

    full = true

  [../]

[]



[Executioner]

  type = Transient

  scheme = bdf2

  solve_type = NEWTON

  # petsc_options_iname = '-pc_type -sub_pc_type -ksp_gmres_restart'

  # petsc_options_value = 'asm       lu           31'

  petsc_options_iname = '-pc_type -sub_pc_type'

  petsc_options_value = 'asm       ilu        '

 # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'

  #petsc_options_value = 'lu    superlu_dist'


  nl_abs_tol = 1e-08

  nl_rel_tol = 1e-07

  l_max_its = 30

  nl_max_its = 15

  end_time = 1500

  [./TimeStepper]

    type = IterationAdaptiveDT

    optimal_iterations = 10

    iteration_window = 2

    dt = 0.00002

    growth_factor = 1.1

    cutback_factor = 0.8

  [../]

  [./Adaptivity]

    initial_adaptivity = 3

    refine_fraction = 0.8

    coarsen_fraction = 0.2

    cycles_per_step = 3

    max_h_level = 7

   # interval = 2

  [../]

  dtmax = 2

[]



[Outputs]

  csv = true

  perf_graph = true

  print_linear_residuals = false

 checkpoint = true

  [./exodus]

    type = Exodus

    interval = 5

    execute_on = 'INITIAL TIMESTEP_END FINAL'

  [../]

  [./log]

    type = Console

    output_file = true

  [../]

[]
