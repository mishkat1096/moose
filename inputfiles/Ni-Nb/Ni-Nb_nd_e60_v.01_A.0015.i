# Setting up the domain. In this formulation ymax should always be 0
[Mesh]
  type = GeneratedMesh
  dim = 2 # Dimension of the mesh
  ymin = -400
  xmin = 0
  xmax = 600
  ymax = 0
  nx = 15 # No of elements in X
  ny = 30 # No of elements in Y
  uniform_refine = 3
[]

# The variable block contains the Variables (in this example U and phi) and the ICs
[Variables]
  [./phi]
  [./InitialCondition]
     type = SmoothSuperellipsoidIC # Initial seed
     variable = phi # phi variable
     x1 = 300 # X coordinate of the seed
     y1 = -400 # Y coordinate of the seed
     a = 8 # Semiaxis a of the seed
     b = 16 # Semiaxis b of the seed
     n = 2 # Exponent
     radius = 3 # Radius of the seed
     invalue = 1 # Solid in the inside of the seed
     outvalue = -1 # Liquid on the outside of the seed
     int_width = 3
    [../]
  [../]
  [./U]
     initial_condition = -1 # IC for U
  [../]
[]

# Here the weak form for the PDE's are defined
[Kernels]
  [./dUdt] # Calculates dU/dt
    type = TimeDerivative
    variable = U
  [../]
  [./Udiffusion] # Calculates grad.D*(1-phi)/2 grad(u)
    type = MatDiffusion
    variable = U
    diffusivity = D
    args = phi
  [../]
  [./Ucoupledphi] # Calculates (1+(1-k)U)/2 dphi/dt
    type = CoupledSusceptibilityTimeDerivative
    variable = U
    v = phi
    f_name = Coef
    args = 'phi'
  [../]
  [./Anti_trapping] # Calculates dphi/dt * grad(U)/magnitude(grad(Us))
    type = AntitrappingCurrent
    variable = U
    v = phi
    args = phi
    f_name = Antitrapping
  [../]
  [./dphidt] # Calculates dphi/dt
    type = TimeDerivative
    variable = phi
  [../]
  [./phibulk] # Calculates df/dphi
    type = AllenCahn
    variable = phi
    f_name = f_chem
    mob_name = L
    args = 'U'
  [../]
  [./phi_surfaceanisotropy1]
    type = ACInterfaceKobayashi # The ACInterfaceKobayashi is particularly for
                                # directional solidification, else use ACInterfaceKobayashi1
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

# AuxVariables are used for postprocessing
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

# AuxKernels are used for the calculation of AuxVariables
[AuxKernels]
  [./z]
    type = MaterialRealAux
    property = vel # interface Velocity
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

# To define a random function. (Parsed function in materials block also can define
# a function but can't depend on coordinate axis)
[Functions]
  [./y]
    type = ParsedFunction
    value = 'y'
  [../]
[]

# Here material constants and properties are calculated
[Materials]
  [./consts]
    type = GenericConstantMaterial
    prop_names  = 'Dl a1 a2 e G d pv m ci ke A'
    prop_values = '3 .8839 .6267 60 .4 .008 .01 10.5 5 0.48 0.0015'
    # Dl - Diffusion coefficient
    # a1 and a2 are constants. These comes from an asymptotic analysis.
    # e - W/d, signifies how large the interface will be. As cooling rate (G*V) gets higher, e should be smaller.
    # G - Thermal gradient, a process parameter
    # d- Diffusion length, a material constant
    # pv - Pull velocity, process parameter
    # m - Liquidous slope, matrial property
    # ci - Alloy concentration
    # ke - Equillibrium partitioning coeff., material property
    # A - Trapping parameter, found form A = Dl/W*Vd, Vd (diffusion velocity)
    #     (A should be set to 0 for classical Antitrapping model)
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
  [./free_energy] # Provides f for the AllenCahn Kernel
    type = DerivativeParsedMaterial
    f_name = f_chem
    args = 'phi U'
    material_property_names = 'vp lt_til a1 e'
    function = ' -0.5*phi^2 + 0.25*phi^4 + a1 * e * phi *(1-2/3*phi^2+0.2*phi^4)*( U + vp/lt_til )'
    outputs = exodus
  [../]
  [./vp] # Defines vp that is a part of f
    type = DerivativeParsedMaterial
    f_name = vp
    material_property_names = 'y pv time tau e d'
    function = 'y - pv * tau * time/(e*d)'
    outputs = exodus
  [../]
  [./lt_til] # Defines lt_til that is a part of f
    type = ParsedMaterial
    f_name = lt_til
    material_property_names = 'lt e d'
    function = 'lt/(e*d)'
    outputs = exodus
  [../]
  [./tau] # Defines the relaxation time, part of f
    type = ParsedMaterial
    f_name = tau
    material_property_names = 'a1 a2 e d Dl'
    function = 'a1 * a2 * (e/Dl) * (e*d)^2'
    outputs = exodus
  [../]
  [./Anti_current] # Defines the function used in antitrapping
    type = DerivativeParsedMaterial
   args = 'U phi'
   f_name = Antitrapping
   material_property_names = 'ke A'
   function = '2*.35* ( 1 - A * (1- phi^2)) * ( 1 + (1-ke) * U )/ ((1+ke) - (1-ke)*phi)'
   # This antitrapping function defines the modified antitrapping current. Set A=0 for "classical" antitrapping model.
   outputs = exodus
  [../]
  [./ke] # Calculates interface velocity, used in post postprocessing
    type = InterfaceVelocity
    w = phi
  [../]
  [./W]
    type = InterfaceOrientationMaterial
    op = phi
    mode_number = 4
    anisotropy_strength = -0.03 # Anisotropic strenght should be (-).
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
  [./til_D] # Defines diffusivity D for MatDiffusion
    type = DerivativeParsedMaterial
    f_name = D
    args = 'phi'
    material_property_names = 'a1 a2 e ke'
    function = 'a1 * a2 * e * (1- phi)/ ((1+ke) - (1-ke)*phi)'
    outputs = exodus
  [../]
  [./Lt] # Defines lt used in lt_til
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
  [./Coef] # Used for CoupledSusceptibilityTimeDerivative kernel (f_name)
    type = DerivativeParsedMaterial
    f_name = Coef
    args = 'U phi'
    material_property_names = 'ke'
    function = '-(1+(1-ke)*U) / ((1+ke) - (1-ke)*phi)'
    outputs = exodus
  [../]
[]

# This block defines boundary conditions.
# We are using noflux BC in all boundaries
[BCs]
  [./Neumann_Bc]
    type = ADNeumannBC
    variable = 'phi'
    boundary = 'top bottom left right'
    value = 0
  [../]
  [./Neumann_BcU]
    type = ADNeumannBC
    variable = 'U'
    boundary = 'top bottom left right'
    value = 0
  [../]
[]

# This block contains Postprocessors
[Postprocessors]
  [./memory]
    type = MemoryUsage
    mem_type = physical_memory
    report_peak_value = true
    execute_on = 'LINEAR NONLINEAR TIMESTEP_END'
  [../]
  [./tip_pos] # Location of dendrite tip along the line
    type = FindValueOnLine
    start_point = '300 -400 0'
    end_point = '300 0 0'
    v = phi
    target = 0
    tol = 1e-6
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./z] # Velocity of the tip
     type = FindVariableValueOnLine
     v = z
     location = tip_pos
     start_point = '300 -400 0'
     end_point = '300 0 0'
     execute_on = 'INITIAL TIMESTEP_END'
   [../]
   [./p] # Ke
      type = FindVariableValueOnLine
      v = p
      location = tip_pos
      start_point = '300 -400 0'
      end_point = '300 0 0'
      execute_on = 'INITIAL TIMESTEP_END'
    [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

# Moose solver parameters
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
  end_time = 1900
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
