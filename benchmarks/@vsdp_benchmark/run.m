function obj = run (obj, filter_name, filter_bm, filter_solver, dry_run)
% RUN  Run the VSDP benchmark.
%
%   obj.run ()  Runs all benchmarks, specified in obj.BENCHMARK with all
%               solvers from obj.SOLVER.  Computed are an approximate solution
%               and rigorous lower and upper bounds.
%
%   obj.run (filter_name, filter_bm, filter_solver)  Optionally, the benchmark
%               can be run for a subset of the data by applying filters, i.e.
%               regular expressions machted with the "regexp()" function, for
%               the test case name ('filter_name'), the benchmark library
%               ('filter_bm'), and the solver ('filter_solver')
%
%   obj.run (filter_name, filter_bm, filter_solver, dry_run)  Same as before,
%               but specify 'dry_run = true' to avoid the storage of any data.
%               By default 'dry_run' is false.
%
%   See also vsdp_benchmark.
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)

bm_indices = 1:length(obj.BENCHMARK);
% Filter benchmarks.
if ((nargin > 1) && ~isempty (filter_name))
  bm_indices = find (cellfun (@(x) ~isempty (regexp (x, filter_name, 'once')), ...
    {obj.BENCHMARK.name}));
else
  filter_name = '.*';
end
% Filter benchmark libraries.
if ((nargin > 2) && ~isempty (filter_bm))
  idx = cellfun (@(x) ~isempty (regexp (x, filter_bm, 'once')), ...
    {obj.BENCHMARK(bm_indices).lib});
  bm_indices = bm_indices(idx);
else
  filter_bm = '.*';
end
if ((nargin > 1) && (length (obj.BENCHMARK) > length (bm_indices)))
  if (~isempty (bm_indices))
    disp ('Run only a subset of the benchmarks:')
    sub_entries = {obj.BENCHMARK(bm_indices).lib; obj.BENCHMARK(bm_indices).name};
    fprintf ('  %s/%s\n', sub_entries{:});
  else
    error ('VSDP_BENCHMARK:run:filterBenchmarks', ...
      ['run: filter_name = ''%s'' and filter_bm = ''%s'' do not match ', ...
      'any benchmark test case.'], filter_name, filter_bm);
  end
end

solver_indices = 3:length(obj.SOLVER);
% Filter solver.
if ((nargin > 3) && ~isempty (filter_solver))
  idx = cellfun (@(x) ~isempty (regexp (x, filter_solver, 'once')), ...
    {obj.SOLVER(solver_indices).name});
  solver_indices = solver_indices(idx);
  if (~isempty (solver_indices))
    disp ('Use only the solver(s):')
    fprintf ('  %s\n', obj.SOLVER(solver_indices).name);
  else
    error ('VSDP_BENCHMARK:run:filterSolver', ...
      'run: filter_solver = ''%s'' does not match any solver.', filter_solver);
  end
end
dry_run = false;
if (nargin > 4)
  dry_run = logical (dry_run);
end

% Solve selected test cases.
for j = bm_indices
  fprintf ('(%3d/%3d) %s/%s\n', find (j == bm_indices), length (bm_indices), ...
    obj.BENCHMARK(j).lib, obj.BENCHMARK(j).name);
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
  
  % Display dimension info.
  fprintf ('          m = %d, n = %d\n', vsdp_obj.m, vsdp_obj.n);
  
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
  for i = solver_indices
    try
      fprintf ('  %s:\n', obj.SOLVER(i).name);
      
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
      [fp, fd] = deal (vsdp_obj.solutions.approximate.f_objective);
      
      % Save or verify cached results.
      if (~dry_run)
        set_or_compare (obj, j, 'fp', fp);
        set_or_compare (obj, j, 'fd', fd);
        set_or_compare (obj, j, 'ts', ts);
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
        set_or_compare (obj, j, 'fL', fL);
        set_or_compare (obj, j, 'tL', tL);
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
        set_or_compare (obj, j, 'fU', fU);
        set_or_compare (obj, j, 'tU', tU);
        obj.save_state ();
      end
      fprintf ('done.\n');
      
      %TODO: to disp.
      mup = (fp - fd)/max(1,(abs(fp) + abs(fd))/2);
      muv = (fU - fL)/max(1,(abs(fL) + abs(fU))/2);
    catch err
      fprintf (2, '\n\n%s\n\n', err.message);
      continue;
    end
  end
end
end

function set_or_compare (obj, idx, fname, val)
% SET_OR_COMPARE  Set value 'val' to the BENCHMARK field 'fname' at index 'idx'.
%   If the value is already set, the values are only compared and a warning is
%   issued, if they differ.
%

current_val = getfield (obj.BENCHMARK(idx), fname);
if (current_val == '?')
  obj.BENCHMARK(idx) = setfield (obj.BENCHMARK(idx), fname, val);
elseif (current_val ~= val)
  warning ('VSDP_BENCHMARK:run:fieldvalueDiffers', ...
    'run: obj.BENCHMARK(%d).%s = ''%f'', not ''%f''.  Name = ''%s''.', ...
    idx, fname, current_val, val, obj.BENCHMARK(idx).name);
end
end
