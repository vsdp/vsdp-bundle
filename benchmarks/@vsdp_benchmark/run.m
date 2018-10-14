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
  bm_indices = find (cellfun (@(x) ~isempty (regexp (x, filter_name)), ...
    {obj.BENCHMARK.name}));
else
  filter_name = '*';
end
% Filter benchmark libraries.
if ((nargin > 2) && ~isempty (filter_bm))
  idx = find (cellfun (@(x) ~isempty (regexp (x, filter_bm)), ...
    {obj.BENCHMARK(bm_indices).lib}));
  bm_indices = bm_indices(idx);
else
  filter_bm = '*';
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
  idx = find (cellfun (@(x) ~isempty (regexp (x, filter_solver)), ...
    {obj.SOLVER(solver_indices).name}));
  solver_indices = solver_indices(idx)
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
  fprintf ('(%3d/%3d) %s/%s\n', find (j, bm_indices), length (bm_indices), ...
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
    vsdp_obj = [];
    switch (fext)
      case '.mat'  % MAT-file.
        load (dfile);
        sprintf('delete (''%s*'');\n', tmp_file);
        if (exist ('A', 'var') == 1)
          vsdp_obj = vsdp (A, b, c, K);
          clear ('A', 'b', 'c', 'K');
        else
          vsdp_obj = vsdp (At, b, c, K);
          clear ('At', 'b', 'c', 'K');
        end
      case '.dat-s'  % Sparse SDPA data.
        vsdp_obj = vsdp.from_sdpa_file (dfile);
      case '.SIF'
        vsdp_obj = vsdp.from_mps_file (dfile);
      otherwise
        warning ('VSDP_BENCHMARK:run:unsupportedData', ...
          'run: Unsupported file ''%s''.', obj.BENCHMARK(j).file);
        continue;
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
    set_or_compare (obj, j, 'K.f', vsdp_obj.K.f > 0);
    set_or_compare (obj, j, 'K.l', vsdp_obj.K.l > 0);
    set_or_compare (obj, j, 'K.q', isempty (vsdp_obj.K.q));
    set_or_compare (obj, j, 'K.s', isempty (vsdp_obj.K.s));
    obj.save_state ();
  end
  
  % Call all selected solvers.
  for i = solver_indices
    try
      fprintf ('  %s:\n', obj.SOLVER(i).name);
      
      % Specify file names.
      app_sol_file = fullfile (obj.RESULT_DIR, 'data', ...
        sprintf ('%s_%s_%s_approximate_solution.mat', ...
        obj.BENCHMARK(j).lib, obj.BENCHMARK(j).name, obj.SOLVER(i).name));
      rig_lbd_file =  fullfile (obj.RESULT_DIR, 'data', ...
        sprintf ('%s_%s_%s_rigorous_lower_bound.mat', ...
        obj.BENCHMARK(j).lib, obj.BENCHMARK(j).name, obj.SOLVER(i).name));
      rig_ubd_file =  fullfile (obj.RESULT_DIR, 'data', ...
        sprintf ('%s_%s_%s_rigorous_upper_bound.mat', ...
        obj.BENCHMARK(j).lib, obj.BENCHMARK(j).name, obj.SOLVER(i).name));
      
      % Make a clean copy and set the solver to be used.
      vsdp_obj = vsdp (vsdp_obj);
      vsdp_obj.options.SOLVER = obj.SOLVER(i).name;
      
      % Solve problem approximately.
      fprintf ('    Approximate solution...');
      if ()
        vsdp_obj.solve (obj.SOLVER(i).name);
        %TODO: save ()
      else
        %TODO: load ()
        vsdp_obj.add_solution ();
      end
      ts = vsdp_obj.solutions.approximate.solver_info.elapsed_time;
      [fp, fd] = deal (vsdp_obj.solutions.approximate.f_objective);
      
      if (~dry_run)
        set_or_compare (obj, j, 'fp', fp);
        set_or_compare (obj, j, 'fd', fd);
        set_or_compare (obj, j, 'ts', ts);
        obj.save_state ();
      end
      fprintf ('done.\n');
      
      % Compute rigorous lower bound.
      fprintf ('    Rigorous lower bound...');
      vsdp_obj.rigorous_lower_bound ();
      tL = vsdp_obj.solutions.rigorous_lower_bound.solver_info.elapsed_time;
      fL = vsdp_obj.solutions.rigorous_lower_bound.f_objective(1);
      if (~dry_run)
        set_or_compare (obj, j, 'fL', fL);
        set_or_compare (obj, j, 'tL', tL);
        obj.save_state ();
      end
      %TODO: save ()
      fprintf ('done.\n');
      
      % Compute rigorous upper bound.
      fprintf ('    Rigorous upper bound...');
      vsdp_obj.rigorous_upper_bound ();
      tu = vsdp_obj.solutions.rigorous_upper_bound.solver_info.elapsed_time;
      fU = vsdp_obj.solutions.rigorous_upper_bound.f_objective(2);
      if (~dry_run)
        set_or_compare (obj, j, 'fU', fU);
        set_or_compare (obj, j, 'tU', tU);
        obj.save_state ();
      end
      %TODO: save ()
      fprintf ('done.\n');
      
      %TODO: to disp.
      mup = (ps - ds)/max(1,(abs(ps) + abs(ds))/2);
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
  setfield (obj.BENCHMARK(idx), fname, val);
elseif (current_val ~= val)
  warning ('VSDP_BENCHMARK:run:fieldvalueDiffers', ...
    'run: obj.BENCHMARK(%d).%s = ''%f'', not ''%f''.  Name = ''%s''.', ...
    idx, fname, current_val, val, obj.BENCHMARK(idx).name);
end
end
