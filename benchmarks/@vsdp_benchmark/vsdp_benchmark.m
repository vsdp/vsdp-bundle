classdef vsdp_benchmark < handle
  % VSDP_BENCHMARK Benchmark class for VSDP.
  %
  %   See also vsdp.
  
  properties
    % Absolute directory path where the benchmarks can be found.
    %
    % Default: The directory of the vsdp_benchmark class.
    BENCHMARK_DIR
    
    % A cell array of initialized solver strings.
    %
    % The benchmark programm assumes, that all solver
    %
    % Default: {}.
    SOLVER
    
    % Temporary absolute directory path for data storage.
    %
    % Default: Output of 'tempname()'.
    TMP_DIR
  end
  
  methods
    function obj = set_default_values (obj)
      % SET_DEFAULT_VALUES for a VSDP benchmark.
      %
      %   Detailed explanation goes here
      %
      
      benchmark_dir = mfilename ('fullpath');
      benchmark_dir(end - 2 * length (mfilename ()) - 2:end) = [];
      obj.BENCHMARK_DIR = benchmark_dir;
      obj.TMP_DIR       = tempname ();
      
      % Add required solvers.
      solver_dir = strrep (benchmark_dir, 'benchmarks', 'solver');
      obj.add_solver ('intlab', @() (exist ('isintval', 'file') == 2), ...
        fullfile (solver_dir, 'intlab'), @() startintlab ());
      obj.add_solver ('vsdp',   @() (exist ('install_vsdp', 'file') == 2), ...
        fullfile (solver_dir, '..', 'vsdp', '2018'), @() install_vsdp ());
      
      % Add optional solvers.
      obj.add_solver ('sdpt3', @() (exist ('sqlp', 'file') == 2), ...
        fullfile (solver_dir, 'sdpt3'), @() install_sdpt3 ());
      obj.add_solver ('sedumi', @() (exist ('sedumi', 'file') == 2), ...
        fullfile (solver_dir, 'sedumi'), @() install_sedumi ());
      obj.add_solver ('sdpa', @() (exist ('sdpam', 'file') == 2), ...
        fullfile (solver_dir, 'sdpa', 'mex'), @() addpath (pwd ()));
      obj.add_solver ('csdp', @() (exist ('csdp', 'file') == 2), ...
        fullfile (solver_dir, 'csdp', 'matlab'), @() addpath (pwd ()));
      obj.add_solver ('mosek', @() (exist ('mosekopt', 'file') == 3), ...
        fullfile (solver_dir, 'mosek', '8', 'toolbox', 'r2014aom'), ...
        @() addpath (pwd ()));
    end
    
    
    function set.BENCHMARK_DIR (obj, p)
      obj.BENCHMARK_DIR = obj.check_dir (p);
    end
    
    
    function set.TMP_DIR (obj, p)
      if (~isdir (p))
        mkdir (p);
      end
      obj.TMP_DIR = obj.check_dir (p);
    end
    
    
    function p = check_dir (~, p)
      % CHECK_DIR  Check 'p' to be an existing directory.
      %
      %   Return the absolute path 'p' or an emtpy array '[]'.
      
      P = what (p);
      if (isdir (p) && ~isempty (P))
        p = P.path;
      else
        warning ('VSDP_BENCHMARK:check_dir:noDir', ...
          'check_dir: Assigned directory ''%s'' does not exist', p);
        p = [];
      end
    end
  end
end

