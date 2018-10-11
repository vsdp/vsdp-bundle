classdef vsdp_benchmark < handle
  % VSDP_BENCHMARK Benchmark class for VSDP.
  %
  %   See also vsdp.
  %
  
  % Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)
  
  properties
    % Absolute directory path where the benchmarks can be found.
    %    The output structure contains a list with the field:
    %
    %      lib    Benchmark library name.
    %      name   Short name for the test case.
    %      file   System dependend full path of the original test case data.
    %      setup  Neccessary code to create a VSDP object 'obj'.
    %
    % Default: [].
    BENCHMARK
    
    % A cell array of initialized solver strings.
    %
    % The benchmark programm assumes, that all solver
    %
    % Default: {'csdp', 'mosek', 'sdpa', 'sdpt3', 'sedumi'}.
    SOLVER
    
    % Absolute directory path for persistent data storage.
    %
    % Default: Subdirectory 'result' of current directory.
    RESULT_DIR
    
    % Temporary absolute directory path for data storage.
    %
    % Default: Output of 'tempname()'.
    TMP_DIR
  end
  
  methods
    function obj = vsdp_benchmark (dir)
      if (nargin > 0)
        obj.RESULT_DIR = dir;
      else
        obj.RESULT_DIR = 'result';
      end
    end
    
    function obj = set_default_values (obj)
      % SET_DEFAULT_VALUES for a VSDP benchmark.
      %
      %   Detailed explanation goes here
      %
      
      obj.TMP_DIR = tempname ();
      
      % Determine default directories.
      benchmark_dir = mfilename ('fullpath');
      benchmark_dir(end - 2 * length (mfilename ()) - 2:end) = [];
      solver_dir = strrep (benchmark_dir, 'benchmarks', 'solver');
      
      % Add required solvers.
      obj.add_solver ('intlab', @() (exist ('isintval', 'file') == 2), ...
        fullfile (solver_dir, 'intlab'), @() startintlab ());
      obj.add_solver ('vsdp',   @() (exist ('install_vsdp', 'file') == 2), ...
        fullfile (solver_dir, '..', 'vsdp', '2018'), @() install_vsdp ());
      
      % Add optional solvers.
      obj.add_solver ('csdp', ...
        @() (exist ('csdp', 'file') == 2), ...
        fullfile (solver_dir, 'csdp', 'matlab'), ...
        @() addpath (pwd ()));
      obj.add_solver ('mosek', ...
        @() (exist ('mosekopt', 'file') == 3), ...
        fullfile (solver_dir, 'mosek', '8', 'toolbox', 'r2014aom'), ...
        @() addpath (pwd ()));
      obj.add_solver ('sdpa', ...
        @() (exist ('sdpam', 'file') == 2), ...
        fullfile (solver_dir, 'sdpa', 'mex'), ...
        @() addpath (pwd ()));
      obj.add_solver ('sdpt3',  ...
        @() (exist ('sqlp', 'file') == 2), ...
        fullfile (solver_dir, 'sdpt3'), ...
        @() install_sdpt3 ());
      obj.add_solver ('sedumi', ...
        @() (exist ('sedumi', 'file') == 2), ...
        fullfile (solver_dir, 'sedumi'), ...
        @() install_sedumi ());
      
      % Add default benchmarks in same directory.
      obj.add_benchmark ('DIMACS', ...
        fullfile (benchmark_dir, 'DIMACS', 'data', '**', '*.mat.gz'), ...
        @(str) str(1:end - length('.mat.gz')));
      
      obj.add_benchmark ('ESC', ...
        fullfile (benchmark_dir, 'ESC', 'data', '*.dat-s.gz'), ...
        @(str) strtok (str, "_"));
      
      obj.add_benchmark ('RDM', ...
        fullfile (benchmark_dir, 'RDM', 'data', '*.dat-s.gz'), ...
        @(str) strtok (str, "_"));
      
      obj.add_benchmark ('SDPLIB', ...
        fullfile (benchmark_dir, 'SDPLIB', 'data', '*.dat-s'), ...
        @(str) str(1:end - length('.dat-s')));
      
      obj.add_benchmark ('SPARSE_SDP', ...
        fullfile (benchmark_dir, 'SPARSE_SDP', 'data', '*.dat-s.gz'), ...
        @(str) str(1:end - length('.dat-s.gz')));
    end
    
    
    function set.RESULT_DIR (obj, p)
      if (~isdir (p))
        mkdir (p);
      end
      obj.RESULT_DIR = obj.check_dir (p);
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
          'check_dir: The directory ''%s'' does not exist', p);
        p = [];
      end
    end
  end
end
