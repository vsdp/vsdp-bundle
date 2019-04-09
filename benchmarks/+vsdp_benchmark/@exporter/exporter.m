classdef vsdp_benchmark_exporter < handle
  % VSDP_BENCHMARK_EXPORTER
  %
  %   Detailed explanation goes here
  %
  
  % Copyright 2004-2019 Kai T. Ohlhus (kai.ohlhus@tuhh.de)
  
  properties (GetAccess = public, SetAccess = protected)
    data_dir
    cdata
    cdata_view
  end
  
  properties (Access = protected)
    tmp_dir
  end
  
  methods
    function obj = vsdp_benchmark_exporter (data_dir, use_cache)
      % VSDP_BENCHMARK_EXPORTER Constructor.
      %
      %    obj = vsdp_benchmark_exporter (data_dir)  Reads all the benchmarks
      %                                in data_dir and creates a cache in the
      %                                directory above.
      %
      %    obj = vsdp_benchmark_exporter (data_dir, false)  Same as above, but
      %                                does not use any cache.
      
      if (~exist (data_dir, 'dir'))
        error ('VSDP:vsdp_benchmark_exporter', ...
          'vsdp_benchmark_exporter: Directory ''%s'' does not exist.', ...
          data_dir);
      end
      obj.data_dir = data_dir;
      obj.tmp_dir = tempname ();
      mkdir (obj.tmp_dir);
      
      % Use cache if applicable.
      if (((nargin > 1) && use_cache) ...
          || (exist (obj.cache_file_name, 'file') == 2))
        obj.load_cache ();
      else
        obj.create_cache ();
      end
    end
    
    function disp (obj)
      fprintf (' VSDP Benchmark\n\n');
      fprintf ('  Data directory:\n    %s\n\n', obj.data_dir);
      
      if (~isempty (obj.cdata_view))
        cview = obj.cdata_view;
      else
        cview = obj.cdata;
      end
      
      if (any (size (cview) > [10, 3]))
        truncation_msg = ' (truncated)';
      else
        truncation_msg = '';
      end
      
      fprintf ('  Current view%s:\n\n', truncation_msg);
      disp (cview(1:min(10,size(cview,1)),1:min(3,size(cview,2))));
    end
    
    function str = cache_file_name (obj)
      str = fullfile (obj.data_dir, '..', 'benchmark_cache.mat');
    end
    
    function create_cache (obj)
      % CREATE_CACHE  Cache the data of obj.data_dir.
      %
      
      obj.cdata = obj.get_test_cases ();
      obj.gather_data ();
      obj.save_cache ();
    end
    
    function save_cache (obj)
      cdata_cache = obj.cdata;
      save (obj.cache_file_name, '-v7', 'cdata_cache')
    end
    
    function load_cache (obj)
      load (obj.cache_file_name, 'cdata_cache');
      obj.cdata = cdata_cache;
    end
    
    function cdata = get_test_cases (obj)
      % GET_TEST_CASES  Parse directory obj.data_dir to get a cell list
      %                 with format {'lib', 'test case', 'solver'}.
      %
      
      file_list = dir ([obj.data_dir, filesep(), '*.mat']);
      idx = {file_list.name}';
      
      % Strip solution type appendix.
      idx = cellfun (@(x) strsplit (x, {'_rigorous_', '_approximate_'}), ...
        idx, 'UniformOutput', false);
      idx = cellfun (@(x) x(1), idx, 'UniformOutput', false);
      cdata = vertcat (idx{:});
      
      % Make test cases unique.
      [~,idx] = unique (cdata);
      cdata = cdata(sort(idx),:);
      
      % Split into benchmark, test case, and solver.
      cdata = cellfun (@(x) strsplit (x, '_'), cdata, 'UniformOutput', false);
      
      % Treat names with underscore in it.
      idx = cellfun (@(x) length (x) > 3, cdata);
      cdata(idx) = cellfun (@(x) [x(1), strjoin(x(2:3), '_') x(4)], ...
        cdata(idx), 'UniformOutput', false);
      cdata = vertcat (cdata{:});
    end
    
    function gather_data (obj)
      len = size (obj.cdata, 1);
      for i = 1:len
        fprintf ('  (%3d/%3d) %-10s %-10s %-10s\n', i, len, obj.cdata{i,1:3});
        vsdp_obj = obj.get_vsdp_obj (obj.cdata{i,1:3});
        obj.get_vsdp_solutions (obj.cdata(i,1:3), vsdp_obj);
        obj.cdata(i,4:5) = {vsdp_obj.m, vsdp_obj.n};
        obj.cdata(i,6:9) = {vsdp_obj.K.f > 0, vsdp_obj.K.l > 0, ...
          ~isempty(vsdp_obj.K.q), ~isempty(vsdp_obj.K.s)};
        if (~isempty (vsdp_obj.solutions.approximate))
          obj.cdata(i,10:12) = { ...
            vsdp_obj.solutions.approximate.f_objective(1), ...
            vsdp_obj.solutions.approximate.f_objective(2), ...
            vsdp_obj.solutions.approximate.solver_info.elapsed_time};
        end
        if (~isempty (vsdp_obj.solutions.rigorous_lower_bound))
          obj.cdata(i,13:14) = { ...
            vsdp_obj.solutions.rigorous_lower_bound.f_objective(1), ...
            vsdp_obj.solutions.rigorous_lower_bound.solver_info.elapsed_time};
        end
        if (~isempty (vsdp_obj.solutions.rigorous_upper_bound))
          obj.cdata(i,15:16) = { ...
            vsdp_obj.solutions.rigorous_upper_bound.f_objective(2), ...
            vsdp_obj.solutions.rigorous_upper_bound.solver_info.elapsed_time};
        end
      end
      % Add header line.
      obj.cdata = [{'lib', 'name' 'sname', 'm', 'n', ...
        'K_f', 'K_l', 'K_q', 'K_s', 'fp', 'fd', 'ts', 'fL', 'tL', ...
        'fU', 'tU'}; obj.cdata];
    end
    
    function obj = get_vsdp_obj (obj, lib, name, solver)
      persistent last_obj;
      persistent last_lib;
      persistent last_name;
      persistent last_solver;
      if (strcmp (lib, last_lib) && strcmp (name, last_name) ...
          && strcmp (solver, last_solver))
        obj = last_obj;  % Just return the already constructed object.
        return;
      elseif (strcmp (lib, last_lib) && strcmp (name, last_name))
        obj = vsdp (last_obj);  % Make a clean copy.
      else
        switch (lib)
          case 'DIMACS'
            src_file = dir (fullfile (lib, 'data', '**', '*.mat.gz'));
            if (length (src_file) > 1)
              error ('VSDP:vsdp_benchmark_exporter', ...
                'vsdp_benchmark_exporter: ''%s'' and ''%s'' is not unique.', ...
                lib, name);
            end
            tmp_file = obj.extract_gz_file (...
              fullfile (src_file.folder, src_file.name));
            load (tmp_file, 'A*', 'b', 'c', 'K');
            if (exist ('A', 'var') == 1)
              obj = vsdp (A, b, c, K);
              clear ('A', 'b', 'c', 'K');
            else
              obj = vsdp (At, b, c, K);
              clear ('At', 'b', 'c', 'K');
            end
          case {'ESC', 'RDM', 'SPARSE_SDP'}
            if (strcmp (lib, 'ESC'))
              src_file = dir (fullfile (lib, 'data', [name, '_*.dat-s.gz']));
            elseif (strcmp (lib, 'RDM'))
              src_file = dir (fullfile (lib, 'data', [name, '.*.dat-s.gz']));
            else
              src_file = dir (fullfile (lib, 'data', [name, '*.dat-s.gz']));
            end
            if (length (src_file) > 1)
              error ('VSDP:vsdp_benchmark_exporter', ...
                'vsdp_benchmark_exporter: ''%s'' and ''%s'' is not unique.', ...
                lib, name);
            end
            tmp_file = obj.extract_gz_file (...
              fullfile (src_file.folder, src_file.name));
            obj = vsdp.from_sdpa_file (tmp_file);
          case 'SDPLIB'
            obj = vsdp.from_sdpa_file (fullfile (lib, 'data', [name, '.dat-s']));
        end
        
        % Finally, delete temporary files.
        if (exist ('tmp_file', 'var') == 1)
          delete (sprintf('%s*', tmp_file));
        end
        
        % Optimize problem structure automatically, no output.
        obj = obj.analyze (true, false);
      end
      last_obj = obj;
      last_lib = lib;
      last_name = name;
      last_solver = solver;
    end
    
    function get_vsdp_solutions (obj, lib_name_solver, vsdp_obj)
      % Try to add approximate solution.
      try
        load (fullfile (obj.data_dir, [strjoin([lib_name_solver, ...
          {'approximate', 'solution'}], '_'), '.mat']), 'app_sol');
        vsdp_obj.add_solution (app_sol.sol_type, app_sol.x, app_sol.y, ...
          app_sol.z, app_sol.f_objective, app_sol.solver_info);
      catch
        % Ignore.
      end
      % Try to add rigorous lower bound.
      try
        load (fullfile (obj.data_dir, [strjoin([lib_name_solver, ...
          {'rigorous', 'lower', 'bound'}], '_'), '.mat']), 'rig_lbd');
        vsdp_obj.add_solution (rig_lbd.sol_type, rig_lbd.x, rig_lbd.y, ...
          rig_lbd.z, rig_lbd.f_objective, rig_lbd.solver_info);
      catch
        % Ignore.
      end
      % Try to add rigorous upper bound.
      try
        load (fullfile (obj.data_dir, [strjoin([lib_name_solver, ...
          {'rigorous', 'upper', 'bound'}], '_'), '.mat']), 'rig_ubd');
        vsdp_obj.add_solution (rig_ubd.sol_type, rig_ubd.x, rig_ubd.y, ...
          rig_ubd.z, rig_ubd.f_objective, rig_ubd.solver_info);
      catch
        % Ignore.
      end
    end
    
    function tmp_file = extract_gz_file (obj, fpath)
      [~, fname, fext] = fileparts (fpath);
      % Copy file to temporary directory.
      tmp_file = fullfile (obj.tmp_dir, [fname, fext]);
      copyfile (fpath, tmp_file);
      % Extract.
      gunzip (tmp_file);
      % Update data for working copy.
      tmp_file((end - length ('.gz') + 1):end) = [];
    end
  end
end
