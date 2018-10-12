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
      
      % Create temprorary directory.
      obj.TMP_DIR = tempname ();
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
