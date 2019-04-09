function cdata = get_test_cases (obj)
% GET_TEST_CASES  Parse directory obj.data_dir to get a cell list
%                 with format {'lib', 'test case', 'solver'}.
%

% Copyright 2018-2019 Kai T. Ohlhus (kai.ohlhus@tuhh.de)

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
