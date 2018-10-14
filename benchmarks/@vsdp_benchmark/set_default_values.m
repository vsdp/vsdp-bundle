function obj = set_default_values (obj)
% SET_DEFAULT_VALUES for a VSDP benchmark.
%
%   Detailed explanation goes here
%
%   See also vsdp_benchmark.
%

% Check for empty result directory (ignore default entries {'.', '..'}).
if (length (dir (obj.RESULT_DIR)) > 2)
  error ('VSDP_BENCHMARK:set_default_values:resultDirNotEmpty', ...
    'set_default_values: RESULT_DIR = ''%s'' is not empty.', ...
    obj.RESULT_DIR);
end

% Determine default directories.
benchmark_dir = fileparts (fileparts (mfilename ('fullpath')));
solver_dir = strrep (benchmark_dir, 'benchmarks', 'solver');

% Add required solvers.
obj.add_solver ('intlab', ...
  @() (exist ('isintval', 'file') == 2), ...
  fullfile (solver_dir, 'intlab'), @() startintlab ());

obj.add_solver ('vsdp', ...
  @() (exist ('install_vsdp', 'file') == 2), ...
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
  @(str) strtok (str, "."));

obj.add_benchmark ('SDPLIB', ...
  fullfile (benchmark_dir, 'SDPLIB', 'data', '*.dat-s'), ...
  @(str) str(1:end - length('.dat-s')));

obj.add_benchmark ('SPARSE_SDP', ...
  fullfile (benchmark_dir, 'SPARSE_SDP', 'data', '*.dat-s.gz'), ...
  @(str) str(1:end - length('.dat-s.gz')));

obj.save_state ();
end
