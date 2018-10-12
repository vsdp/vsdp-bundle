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

if (exist (fullfile (obj.RESULT_DIR, 'benchmark_state.mat'), 'file'))
  load (fullfile (obj.RESULT_DIR, 'benchmark_state.mat'), ...
    'bm_data', 'sol_data');
  obj.BENCHMARK = bm_data;
  obj.SOLVER = sol_data;
else
  warning ('VSDP_BENCHMARK:restore_state:noState', ...
    'restore_state: The directory ''%s'' has no VSDP benchmark data.', ...
    obj.RESULT_DIR);
end
end
