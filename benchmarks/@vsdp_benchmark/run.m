function run (obj, filter_name, filter_bm, filter_solve, dry_run)
% RUN  Run the VSDP benchmark.
%
%   obj.run ()  Runs all benchmarks, specified in obj.BENCHMARK with all
%               solvers from obj.SOLVER.  Computed are an approximate solution
%               and rigorous lower and upper bounds.
%
%   obj.run (filter_name, filter_bm, filter_solve)  Optionally, the benchmark
%               can be run for a subset of the data by applying filters, i.e.
%               regular expressions machted with the "regexp()" function, for
%               the test case name ('filter_name'), the benchmark library
%               ('filter_bm'), and the solver ('filter_solve')
%
%   obj.run (filter_name, filter_bm, filter_solve, dry_run)  Same as before,
%               but specify 'dry_run = true' to avoid the storage of any data.
%               By default 'dry_run' is false.
%
%   See also vsdp_benchmark.
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)

% TODO: Filter
% idx = find (cellfun (@(x) ~isempty (regexp (x, "H.*O")), ...
%   {obj.BENCHMARK.name}));
% obj.BENCHMARK(idx).name

for j = 1:length(obj.BENCHMARK)
  fprintf ('(%3d/%3d) %s/%s\n', j, length(obj.BENCHMARK), ...
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
    
    % Display dimension info.
    fprintf ('          m = %d, n = %d\n', vsdp_obj.m, vsdp_obj.n);
    
    % So
    for i = 3:length(obj.SOLVER)
      fprintf ('  %s:\n', obj.SOLVER(i).name);
      % Make a clean copy and set the solver to be used.
      vsdp_obj = vsdp (vsdp_obj);
      vsdp_obj.options.SOLVER = obj.SOLVER(i).name;
      
      % Solve problem approximately.
      fprintf ('    Approximate solution...');
      vsdp_obj.solve (obj.SOLVER(i).name);
      ts = vsdp_obj.solutions.approximate.solver_info.elapsed_time;
      [ps, ds] = deal (vsdp_obj.solutions.approximate.f_objective);
      %TODO: save ()
      fprintf ('done.\n');
      
      % Compute rigorous lower bound.
      fprintf ('    Rigorous lower bound...');
      vsdp_obj.rigorous_lower_bound ();
      tl = vsdp_obj.solutions.rigorous_lower_bound.solver_info.elapsed_time;
      fL = vsdp_obj.solutions.rigorous_lower_bound.f_objective(1);
      %TODO: save ()
      fprintf ('done.\n');
      
      % Compute rigorous upper bound.
      fprintf ('    Rigorous upper bound...');
      vsdp_obj.rigorous_upper_bound ();
      tu = vsdp_obj.solutions.rigorous_upper_bound.solver_info.elapsed_time;
      fU = vsdp_obj.solutions.rigorous_upper_bound.f_objective(2);
      %TODO: save ()
      fprintf ('done.\n');
      
      %TODO: to disp.
      mup = (ps - ds)/max(1,(abs(ps) + abs(ds))/2);
      muv = (fU - fL)/max(1,(abs(fL) + abs(fU))/2);
    end
  catch err
    fprintf (2, '\n\n%s\n\n', err.message);
    continue;
  end
end
end
