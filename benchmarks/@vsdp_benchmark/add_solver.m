function add_solver (obj, name, check_fun, setup_dir, setup_fun)
% ADD_SOLVER  Sets up a solver for a VSDP benchmark.
%
%   name      The name of the solver.  This name should match the definition in
%             VSDP.
%   check_fun Function to check if the solver is ready to use.
%
%   setup_dir (optional)  Directory where to setup the solver.
%   setup_fun (optional)  Function  call  to setup the solver.
%
%   See also vsdp_benchmark.
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)

narginchk (3, 5);

% Check for solver to be ready.
if (check_fun ())
  obj.SOLVER{end + 1} = name;
  return;
end

% Try to setup the solver.
if (nargin > 3)
  setup_dir = obj.check_dir (setup_dir);
  if (~isempty (setup_dir))
    OLD_DIR = cd (setup_dir);
    setup_fun ();
    cd (OLD_DIR);
  end
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
