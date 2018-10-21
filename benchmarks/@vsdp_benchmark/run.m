function obj = run (obj, f, dry_run)
% RUN  Run the VSDP benchmark.
%
%   obj.run ()  Runs all benchmarks, specified in obj.BENCHMARK with all
%               solvers from obj.SOLVER.  Computed are an approximate solution
%               and rigorous lower and upper bounds.
%
%   obj.run (obj.filter (...))  Optionally, the benchmark can be run for a
%               subset of the data by applying filters, see obj.filter for
%               details.
%
%   obj.run (filter_bm, filter_name, filter_solver, dry_run)  Same as before,
%               but specify 'dry_run = true' to avoid the storage of any data.
%               By default 'dry_run' is false.
%
%   See also vsdp_benchmark.
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)

% If no filter is applied, get all available indices.
if (nargin < 2)
  f = obj.filter ();
else
  % Display some information about the reduced filtered benchmark.
  if (length (obj.BENCHMARK) > length (f.benchmark))
    disp ('Run only a subset of the benchmarks:')
    sub_entries = {obj.BENCHMARK(f.benchmark).lib; ...
      obj.BENCHMARK(f.benchmark).name};
    fprintf ('  %s/%s\n', sub_entries{:});
  end
  disp ('Use only the solver(s):')
  fprintf ('  %s\n', obj.SOLVER(f.solver).name);
end

% Save all computed values by default.
if (nargin < 3)
  dry_run = false;
end

% Define helper functions for diary display.
print_header = @(str) fprintf ('\n%s\n%s\n%s\n\n', repmat ('-', 1, 50), ...
  str, repmat ('-', 1, 50));

% Solve selected test cases.
for j = f.benchmark
  fprintf ('(%3d/%3d) %s/%s\n', find (j == f.benchmark), ...
    length (f.benchmark), obj.BENCHMARK(j).lib, obj.BENCHMARK(j).name);
  log_file = fullfile (obj.RESULT_DIR, 'data', ...
    sprintf('%s_%s.log', obj.BENCHMARK(j).lib, obj.BENCHMARK(j).name));
  diary (log_file);
  print_header (sprintf ('Test : %s/%s\nStart: %s', ...
    obj.BENCHMARK(j).lib, obj.BENCHMARK(j).name, datestr (now ())));
  try
    [fpath, fname, fext] = fileparts (obj.BENCHMARK(j).file);
    
    % Extract *.gz-archive if necessary.
    if (strcmp (fext, '.gz'))
      % Copy file to temporary directory.
      tmp_file = fullfile (obj.TMP_DIR, [fname, fext]);
      copyfile (obj.BENCHMARK(j).file, tmp_file);
      % Extract.
      gunzip (tmp_file);
      % Update data for working copy.
      tmp_file((end - length ('.gz') + 1):end) = [];
      [fpath, fname, fext] = fileparts (tmp_file);
    end
    
    % Import data to VSDP object 'obj' depending on the file type.
    dfile = fullfile (fpath, [fname, fext]);
    switch (fext)
      case '.mat'   % MAT-file.
        load (dfile, 'A*', 'b', 'c', 'K');
        if (exist ('A', 'var') == 1)
          vsdp_obj = vsdp (A, b, c, K);
          clear ('A', 'b', 'c', 'K');
        else
          vsdp_obj = vsdp (At, b, c, K);
          clear ('At', 'b', 'c', 'K');
        end
      case '.dat-s'  % Sparse SDPA data.
        vsdp_obj = vsdp.from_sdpa_file (dfile);
      case '.SIF'    % MPS data.
        vsdp_obj = vsdp.from_mps_file (dfile);
      otherwise
        warning ('VSDP_BENCHMARK:run:unsupportedData', ...
          'run: Unsupported file ''%s''.', obj.BENCHMARK(j).file);
        continue;
    end
    
    % Finally, delete temporary files.
    if (exist ('tmp_file', 'var') == 1)
      delete (sprintf('%s*', tmp_file));
    end
  catch err
    fprintf (2, '\n\n%s\n\n', err.message);
    continue;
  end
    
  % Save problem statistics, if not already done.
  if (~dry_run)
    set_or_compare (obj, j, 'm', vsdp_obj.m);
    set_or_compare (obj, j, 'n', vsdp_obj.n);
    set_or_compare (obj, j, 'K_f', vsdp_obj.K.f > 0);
    set_or_compare (obj, j, 'K_l', vsdp_obj.K.l > 0);
    set_or_compare (obj, j, 'K_q', isempty (vsdp_obj.K.q));
    set_or_compare (obj, j, 'K_s', isempty (vsdp_obj.K.s));
    obj.save_state ();
  end
  
  % Call all selected solvers.
  for i = f.solver
    try
      fprintf ('  %s:\n', obj.SOLVER(i).name);
      if (~dry_run)
        % Determine if there are already benchmarks for solver 'i'.
        ii = get_or_set_solver (obj, j, obj.SOLVER(i).name);
        obj.save_state ();
      end
      
      % Specify file names.
      file_prefix = fullfile (obj.RESULT_DIR, 'data', ...
        sprintf('%s_%s_%s', obj.BENCHMARK(j).lib, ...
        obj.BENCHMARK(j).name, obj.SOLVER(i).name));
      app_sol_file = sprintf ('%s_approximate_solution.mat', file_prefix);
      rig_lbd_file = sprintf ('%s_rigorous_lower_bound.mat', file_prefix);
      rig_ubd_file = sprintf ('%s_rigorous_upper_bound.mat', file_prefix);
      
      % Make a clean copy and set the solver to be used.
      vsdp_obj = vsdp (vsdp_obj);
      vsdp_obj.options.SOLVER = obj.SOLVER(i).name;
      
      % Compute approximate solution, if not already computed.
      fprintf ('    Approximate solution...');
      if (exist (app_sol_file, 'file') ~= 2)
        vsdp_obj.solve (obj.SOLVER(i).name);
        S = warning ('off', 'MATLAB:structOnObject');
        app_sol = struct (vsdp_obj.solutions.approximate);
        warning (S);
        if (~dry_run)
          save (app_sol_file, 'app_sol', '-v7');
        end
      else  % ... or load from file.
        load (app_sol_file, 'app_sol')
        vsdp_obj.add_solution (app_sol.sol_type, app_sol.x, app_sol.y, ...
          app_sol.z, app_sol.f_objective, app_sol.solver_info);
        fprintf (' (cached) ');
      end
      ts = vsdp_obj.solutions.approximate.solver_info.elapsed_time;
      fp = vsdp_obj.solutions.approximate.f_objective(1);
      fd = vsdp_obj.solutions.approximate.f_objective(2);
      
      % Save or verify cached results.
      if (~dry_run)
        set_or_compare (obj, j, 'fp', fp, ii);
        set_or_compare (obj, j, 'fd', fd, ii);
        set_or_compare (obj, j, 'ts', ts + 2, ii);
        obj.save_state ();
      end
      fprintf ('done.\n');
      
      % Compute rigorous lower bound, if not already computed.
      fprintf ('    Rigorous lower bound...');
      if (exist (rig_lbd_file, 'file') ~= 2)
        vsdp_obj.rigorous_lower_bound ();
        S = warning ('off', 'MATLAB:structOnObject');
        rig_lbd = struct (vsdp_obj.solutions.rigorous_lower_bound);
        warning (S);
        if (~dry_run)
          save (rig_lbd_file, 'rig_lbd', '-v7');
        end
      else  % ... or load from file.
        load (rig_lbd_file, 'rig_lbd')
        vsdp_obj.add_solution (rig_lbd.sol_type, rig_lbd.x, rig_lbd.y, ...
          rig_lbd.z, rig_lbd.f_objective, rig_lbd.solver_info);
        fprintf (' (cached) ');
      end
      
      tL = vsdp_obj.solutions.rigorous_lower_bound.solver_info.elapsed_time;
      fL = vsdp_obj.solutions.rigorous_lower_bound.f_objective(1);
      
      % Save or verify cached results.
      if (~dry_run)
        set_or_compare (obj, j, 'fL', fL, ii);
        set_or_compare (obj, j, 'tL', tL, ii);
        obj.save_state ();
      end
      fprintf ('done.\n');
      
      % Compute rigorous upper bound, if not already computed.
      fprintf ('    Rigorous upper bound...');
      if (exist (rig_ubd_file, 'file') ~= 2)
        vsdp_obj.rigorous_upper_bound ();
        S = warning ('off', 'MATLAB:structOnObject');
        rig_ubd = struct (vsdp_obj.solutions.rigorous_upper_bound);
        warning (S);
        if (~dry_run)
          save (rig_ubd_file, 'rig_ubd', '-v7');
        end
      else  % ... or load from file.
        load (rig_ubd_file, 'rig_ubd')
        vsdp_obj.add_solution (rig_ubd.sol_type, rig_ubd.x, rig_ubd.y, ...
          rig_ubd.z, rig_ubd.f_objective, rig_ubd.solver_info);
        fprintf (' (cached) ');
      end
      
      tU = vsdp_obj.solutions.rigorous_upper_bound.solver_info.elapsed_time;
      fU = vsdp_obj.solutions.rigorous_upper_bound.f_objective(2);
      
      % Save or verify cached results.
      if (~dry_run)
        set_or_compare (obj, j, 'fU', fU, ii);
        set_or_compare (obj, j, 'tU', tU, ii);
        obj.save_state ();
      end
      fprintf ('done.\n');
    catch err
      fprintf (2, '\n\n%s\n\n', err.message);
      continue;
    end
  end
  print_header (sprintf ('End: %s', datestr (now ())));
  diary ('off');
end
end

function set_or_compare (obj, idx, fname, val, ii)
% SET_OR_COMPARE  Set  value 'val' to the BENCHMARK field 'fname' at index 'idx'.
%   If the value is already set, the values are only compared and a warning is
%   issued, if they differ.
%
%   Given the fifth argument 'ii', look in 'obj.BENCHMARK(idx).values(ii)'
%   instead.
%

if (nargin > 4)
  S = obj.BENCHMARK(idx).values(ii);
else
  S = obj.BENCHMARK(idx);
end

% Update struct.
current_val = getfield (S, fname);
if (current_val == '?')
  S = setfield (S, fname, val);
elseif (current_val ~= val)
  warning ('VSDP_BENCHMARK:run:fieldValueDiffers', ...
    'run: %s = ''%f'', not ''%f'' in ''obj.BENCHMARK(%d)'' (''%s'').', ...
    fname, current_val, val, idx, obj.BENCHMARK(idx).name);
end

% Store modified struct.
if (nargin > 4)
  obj.BENCHMARK(idx).values(ii) = S;
else
  obj.BENCHMARK(idx) = S;
end
end


function ii = get_or_set_solver (obj, idx, sname)
% GET_OR_SET_SOLVER  Get the index of solver 'sname' in 'obj.BENCHMARK(idx)'.
%   If the solver 'sname' is not present, add a new field to
%   'obj.BENCHMARK(idx).values'.
%


if (isempty (obj.BENCHMARK(idx).values))
  ii = [];
else
  ii = find (cellfun (@(x) strcmp (x, sname), ...
    {obj.BENCHMARK(idx).values.sname}));
end
if (isempty (ii))
  ii = length (obj.BENCHMARK(idx).values) + 1;
  obj.BENCHMARK(idx).values(ii).sname = sname;
  obj.BENCHMARK(idx).values(ii).fp = [];
  obj.BENCHMARK(idx).values(ii).fd = [];
  obj.BENCHMARK(idx).values(ii).ts = [];
  obj.BENCHMARK(idx).values(ii).fL = [];
  obj.BENCHMARK(idx).values(ii).tL = [];
  obj.BENCHMARK(idx).values(ii).fU = [];
  obj.BENCHMARK(idx).values(ii).tU = [];
end

end
