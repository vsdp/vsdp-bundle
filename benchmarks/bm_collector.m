function bm_list = bm_collector (options)
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
%    The output structure contains a list with the field:
%
%      lib    Benchmark library name.
%      name   Short name for the test case.
%      file   System dependend full path of the original test case data.
%      setup  Neccessary code to create a VSDP object 'obj'.
%

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

% Collect benchmark test cases.
old_dir = cd (opts.BENCHMARK_PATH);
bm_list = [];
for i = 1:length (opts.BENCHMARKS)
  bm_list = eval (['get_', opts.BENCHMARKS{i}, '(bm_list);']);
end
cd (old_dir);
end


function opts = get_default_options ()
% All available benchmark folder names.
opts.BENCHMARKS = {'DIMACS', 'ESC', 'RDM', 'SDPLIB', 'SPARSE_SDP'};
% The directory, where this file is located.
opts.BENCHMARK_PATH = mfilename ('fullpath');
opts.BENCHMARK_PATH(end - length (mfilename ()):end) = [];
end


function bm_list = get_DIMACS (bm_list)
% Regard only files with the following file extension:
ext = '.mat.gz';
f = dir (fullfile ('DIMACS', 'data', '**', ['*', ext]));
for i = length(f):-1:1
  bml_DIMACS(i).lib   = 'DIMACS';
  bml_DIMACS(i).name  = f(i).name(1:end - length(ext));
  bml_DIMACS(i).file  = fullfile (f(i).folder, f(i).name);
  bml_DIMACS(i).setup = '';
end
bm_list = [bm_list, bml_DIMACS];
end


function bm_list = get_ESC (bm_list)
% Regard only files with the following file extension:
ext = '.dat-s.gz';
f = dir (fullfile ('ESC', 'data', ['*', ext]));
for i = length(f):-1:1
  bml_ESC(i).lib   = 'ESC';
  bml_ESC(i).name  = strtok (f(i).name, "_");
  bml_ESC(i).file  = fullfile (f(i).folder, f(i).name);
  bml_ESC(i).setup = '';
end
bm_list = [bm_list, bml_ESC];
end


function bm_list = get_RDM (bm_list)
% Regard only files with the following file extension:
ext = '.dat-s.gz';
f = dir (fullfile ('RDM', 'data', ['*', ext]));
for i = length(f):-1:1
  bml_RDM(i).lib   = 'RDM';
  bml_RDM(i).name  = strtok (f(i).name, ".");
  bml_RDM(i).file  = fullfile (f(i).folder, f(i).name);
  bml_RDM(i).setup = '';
end
bm_list = [bm_list, bml_RDM];
end


function bm_list = get_SDPLIB (bm_list)
% Regard only files with the following file extension:
ext = '.dat-s';
f = dir (fullfile ('SDPLIB', 'data', ['*', ext]));
for i = length(f):-1:1
  bml_SDPLIB(i).lib   = 'SDPLIB';
  bml_SDPLIB(i).name  = f(i).name(1:end - length(ext));
  bml_SDPLIB(i).file  = fullfile (f(i).folder, f(i).name);
  bml_SDPLIB(i).setup = 'obj = vsdp.from_sdpa_file (%s);';
end
bm_list = [bm_list, bml_SDPLIB];
end


function bm_list = get_SPARSE_SDP (bm_list)
% Regard only files with the following file extension:
ext = '.dat-s.gz';
f = dir (fullfile ('SPARSE_SDP', 'data', ['*', ext]));
for i = length(f):-1:1
  bml_SPARSE_SDP(i).lib   = 'SPARSE_SDP';
  bml_SPARSE_SDP(i).name  = f(i).name(1:end - length(ext));
  bml_SPARSE_SDP(i).file  = fullfile (f(i).folder, f(i).name);
  bml_SPARSE_SDP(i).setup = '';
end
bm_list = [bm_list, bml_SPARSE_SDP];
end
