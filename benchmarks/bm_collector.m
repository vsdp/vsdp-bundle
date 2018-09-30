function bm_collector (options)
% BM_COLLECTOR  Generates a list of jobs for the benchmark.
%
%    The input structure 'options' may contain the following fields:
%
%      BENCHMARKS   The folders containing benchmarks for VSDP.
%                   Default: {'DIMACS', 'ESC', 'RDM', 'SDPLIB', 'SPARSE_SDP'}
%
%      BENCHMARK_PATH   The path where the benchmarks can be found.
%                       Default: The directory of this file.
%
%    The output 

opts = get_default_options ();

% Override user provided options by default ones.
if (nargin > 0)
  fnames = fieldnames (options);
  for i = 1:length (fnames)
    if (isfield (opts, fnames{i}))
      opts = setfield (opts, fnames{i}, getfield (options, fnames{i}));
    end
  end
end

% Check that all benchmarks exist.
rm_idx = [];
for i = 1:length (opts.BENCHMARKS)
  if (~isdir (fullfile (opts.BENCHMARK_PATH, opts.BENCHMARKS{i})))
    rm_idx(end + 1) = i;
    warning ('VSDP:bm_collector:benchmarkNotFound', ...
      'bm_collector: Benchmark "%s" not found.', opts.BENCHMARKS{i});
  end
end
opts.BENCHMARKS(rm_idx) = [];
if (isempty (opts.BENCHMARKS))
  error ('VSDP:bm_collector:noBenchmarks', ...
      'bm_collector: No benchmarks found.');
end

end


function opts = get_default_options ()
% All available benchmark folder names.
opts.BENCHMARKS = {'DIMACS', 'ESC', 'RDM', 'SDPLIB', 'SPARSE_SDP'};
% The directory, where this file is located.
opts.BENCHMARK_PATH = mfilename ('fullpath');
opts.BENCHMARK_PATH(end - length (mfilename ()):end) = [];
end
