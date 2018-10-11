classdef vsdp_benchmark < handle
  % VSDP_BENCHMARK Benchmark class for VSDP.
  %
  %   See also vsdp.
  
  properties
    % Absolute directory path where the benchmarks can be found.
    %
    % Default: The directory of the vsdp_benchmark class.
    BENCHMARK_DIR
    
    % Absolute directory path where the solvers can be found.
    %
    % Default: The sibling directory 'solver' of BENCHMARK_DIR.
    SOLVER_DIR
    
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
      
      default_dir = mfilename ('fullpath');
      default_dir(end - 2 * length (mfilename ()) - 2:end) = [];
      obj.BENCHMARK_DIR = default_dir;
      obj.SOLVER_DIR    = strrep (default_dir, 'benchmarks', 'solver');
      obj.TMP_DIR       = tempname ();
    end
    
    
    function set.BENCHMARK_DIR (obj, p)
      obj.BENCHMARK_DIR = obj.check_dir (p);
    end
    
    
    function set.SOLVER_DIR (obj, p)
      obj.SOLVER_DIR = obj.check_dir (p);
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

