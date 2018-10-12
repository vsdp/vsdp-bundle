function restore_state (obj)
% RESTORE_STATE  Restores the state of a VSDP benchmark.
%
%   In particular, this functions looks for a file 'benchmark_state.mat' in
%   the object's RESULT_DIR, loads it's content and perfoms additionally:
%
%   - Reinitializes all specified solvers or issues a warning.
%   - Checks for all benchmark files to exist or issues a warning.
%
%   See also vsdp_benchmark.
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)

bm_state_file = fullfile (obj.RESULT_DIR, 'benchmark_state.mat');
if (exist (bm_state_file, 'file') ~= 2)
  warning ('VSDP_BENCHMARK:restore_state:noState', ...
    'restore_state: The directory ''%s'' has no VSDP benchmark data.', ...
    obj.RESULT_DIR);
end

% Restore the used solvers.
load (bm_state_file, 'sol_data');
obj.SOLVER = [];
for i = 1:length (sol_data)
  if (~obj.add_solver (sol_data(i).name, str2func (sol_data(i).check_fun), ...
      sol_data(i).setup_dir, str2func (sol_data(i).setup_fun)));
    obj.SOLVER(end + 1) = sol_data(i);
  end
end

% Restore the benchmark data.
load (bm_state_file, 'bm_data');
obj.BENCHMARK = bm_data;
end
