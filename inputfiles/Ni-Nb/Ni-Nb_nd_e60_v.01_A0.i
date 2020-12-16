[Mesh]

  type = GeneratedMesh

  dim = 2

  ymin = -400

  xmin = 0

  xmax = 200

  ymax = 0

  nx = 15

  ny = 30

  uniform_refine = 3

[]

[Variables]

  [./phi]

  [./InitialCondition]

     type = SmoothSuperellipsoidIC

    #  type = SmoothCircleIC

      variable = phi

      x1 = 100

      y1 = -400

      a = 8

      b = 16

      n = 2

      radius = 3

      invalue = 1

      outvalue = -1

      int_width = 3

    [../]

  [../]

  [./U]

     initial_condition = -1

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

[AuxVariables]

  [./z]

     order = CONSTANT

     family = MONOMIAL

  [../]

  [./p]

     order = CONSTANT

     family = MONOMIAL

  [../]
[]

[AuxKernels]

  [./z]

    type = MaterialRealAux

    property = vel

    variable = z

    execute_on = timestep_end

  [../]

  [./p]

    type = MaterialRealAux

    property = ke

    variable = p

    execute_on = timestep_end

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

    prop_names  = 'Dl a1 a2 e G d pv m ci ke A'

    prop_values = '3 .8839 .6267 60 .4 .008 .01 10.5 5 0.48 0.0'

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

  #  material_property_names = 'Dl ke dt'

  #  function = '2 * (Dl/dt) * ((1-phi)/2) * (1 + (1-ke)*U)'

# [../]

  [./free_energy]

    type = DerivativeParsedMaterial

    f_name = f_chem

    args = 'phi U'

    material_property_names = 'vp lt_til a1 e'

    function = ' -0.5*phi^2 + 0.25*phi^4 + a1 * e * phi *(1-2/3*phi^2+0.2*phi^4)*( U + vp/lt_til )'

    outputs = exodus

  [../]

  [./vp]

    type = DerivativeParsedMaterial

   f_name = vp

    material_property_names = 'y pv time tau e d'

    function = 'y - pv * tau * time/(e*d)'

    outputs = exodus

  [../]

  [./lt_til]

    type = ParsedMaterial

    f_name = lt_til

    material_property_names = 'lt e d'

    function = 'lt/(e*d)'

    outputs = exodus

  [../]

  [./tau]

    type = ParsedMaterial

    f_name = tau

    material_property_names = 'a1 a2 e d Dl'

    function = 'a1 * a2 * (e/Dl) * (e*d)^2'

    outputs = exodus

  [../]

  [./Anti_current]

    type = DerivativeParsedMaterial

   args = 'U phi'

   f_name = Antitrapping

    material_property_names = 'ke A'

    function = '2*.35* ( 1 - A * (1- phi^2)) * ( 1 + (1-ke) * U )/ ((1+ke) - (1-ke)*phi)'

    outputs = exodus

  [../]

  [./ke]

     type = InterfaceVelocity

     w = phi


  [../]

  [./W]

    type = InterfaceOrientationMaterial

    op = phi

    mode_number = 4

    anisotropy_strength = -0.03

    eps_bar = 1

    reference_angle = 0

  [../]

 [./Mobility]

    type = DerivativeParsedMaterial

    f_name = L

    material_property_names = ' eps vp ke lt_til '

    function = '1 /(eps * eps * (1-(1-ke) * vp / lt_til))'

    outputs = exodus

  [../]

  [./til_D]

    type = DerivativeParsedMaterial

    f_name = D

    args = 'phi'

    material_property_names = 'a1 a2 e ke'

    function = 'a1 * a2 * e * (1- phi)/ ((1+ke) - (1-ke)*phi)'

    outputs = exodus

  [../]

  [./Lt]

    type = ParsedMaterial

    f_name = lt

    material_property_names = 'm ci ke G'

    function = 'm * ci * (1-ke)/ (ke * G)'

    outputs = exodus

  [../]

  [./epx]

    type = ParsedMaterial

    f_name = epx

    material_property_names = 'eps'

    function = eps

    outputs = exodus

  [../]

  [./Coef]

    type = DerivativeParsedMaterial

    f_name = Coef

    args = 'U phi'

    material_property_names = 'ke'

    function = '-(1+(1-ke)*U) / ((1+ke) - (1-ke)*phi)'

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

   boundary = 'top bottom '

    value = 0

  [../]

  [./Periodic]

   [./y]

     variable = 'U phi'

     primary = left

     secondary = right

     translation = '200 0 0'

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

  [./tip_pos]

    type = FindValueOnLine

    start_point = '100 -400 0'

    end_point = '100 0 0'

    v = phi

    target = 0

    tol = 1e-6

    execute_on = 'INITIAL TIMESTEP_END'

  [../]

  [./z]

     type = FindVariableValueOnLine

     v = z

     location = tip_pos

     start_point = '100 -400 0'

     end_point = '100 0 0'

     execute_on = 'INITIAL TIMESTEP_END'

   [../]

   [./p]

      type = FindVariableValueOnLine

      v = p

      location = tip_pos

      start_point = '100 -400 0'

      end_point = '100 0 0'

      execute_on = 'INITIAL TIMESTEP_END'

    [../]


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

  nl_max_its = 20

  end_time = 11000

  [./TimeStepper]

    type = IterationAdaptiveDT

    optimal_iterations = 8

    iteration_window = 2

    dt = 0.01

    growth_factor = 1.1

    cutback_factor = 0.8

  [../]

  [./Adaptivity]

    initial_adaptivity = 3

    refine_fraction = 0.9

    coarsen_fraction = 0.2

    cycles_per_step = 3

    max_h_level = 8

   # interval = 2

  [../]

  dtmax = .5

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
