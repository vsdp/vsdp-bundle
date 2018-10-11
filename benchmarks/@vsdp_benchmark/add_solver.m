function add_solver (obj, name, check_fun, setup_dir, setup_fun)
% ADD_SOLVER  Sets up a solver for a VSDP benchmark.
%
%   name      The name of the solver.  This name should match 
%   check_fun
%
%   setup_dir (optional)  Directory where to setup the solver.
%   setup_fun (optional)  Function  call  to setup the solver.
%
%   See also vsdp_benchmark.
%

narginchk (3, 5);

% Check for solver to be ready.
if (check_fun ())
  obj.SOLVER{end + 1} = name;
  return;
end

% Try to setup the solver.
if (nargin > 3)
  OLD_DIR = cd (setup_dir);
  setup_fun ();
  cd (OLD_DIR);
end

% Check for solver to be ready.
if (check_fun ())
  obj.SOLVER{end + 1} = name;
elseif (strcmpi (name, 'intlab'))
  error ('VSDP_BENCHMARK:add_solver:noINTLAB', ...
    ['add_solver: INTLAB is required to run VSDP.  Get a recent version ', ...
    'from  http://www.ti3.tuhh.de/rump/intlab']);
else
  warning ('VSDP_BENCHMARK:add_solver:solverNotReady', ...
    'bm_setup: The solver ''%s'' is not available.', name);
end

end
