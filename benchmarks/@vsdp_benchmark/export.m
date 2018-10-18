function output = export (obj, fmt, out_file, filter, use_columns)
% EXPORT  Export the data of the VSDP benchmark object 'obj'.
%
%   output = obj.export (fmt)  Export all available data to the destination
%     format 'fmt' which is one of 'cell', 'csv', 'html', or 'latex'.  In
%     case of 'fmt' = 'cell', the variable 'output' contains cell array with
%     all available data.  Otherwise a formatted string in the respective
%     format is returned.
%
%   obj.export (fmt, out_file)  Optionally, the output can be written to a
%     non-existing file 'out_file'.  In case of 'fmt' = 'cell', 'out_file' is
%     a MAT-file, otherwise a text file with the data formatted in the
%     respective format 'fmt'.
%
%   obj.export (__, __, obj.filter (...))  Optionally, the benchmark data,
%     i.e. the rows, can be filtered.  See 'obj.filter' for details.  If the
%     argument is empty, all available data will be exported.
%
%   obj.export (__, __, __, use_columns)  Optionally, the exported columns
%     can be set as a column vector of char arrays.  In general every scalar
%     field of 'obj.BENCHMARK' and 'obj.BENCHMARK.values' can be chosen as
%     column name for the export.  Those are:
%
%        use_columns = { ...
%           'lib', 'name' 'file', 'm', 'n', 'K_f', 'K_l', 'K_q', 'K_s',
%           'sname', 'fp', 'fd', 'ts', 'fL', 'tL', 'fU', 'tU'}';
%
%     In addition to the basic data, it is possible to specify extra columns
%     based on those given above by three possible combinations.  For example:
%
%       1. 'tL/ts' will result in a column containing the elementwise quotient
%          of the columns 'tL' and 'ts', even is they are not present in the
%          export.
%       2. 'fU-fL', like in 1., but for the elementwise difference.
%       3. 'mu_fU_fL', computes the relative accurracy of 'fU' and 'fL', see
%          <https://vsdp.github.io/references.html#Jansson2006>.
%
%     When the additional column creation fails, a warning is shown and the
%     column will not be part of the export.
%
%     If 'use_columns' is a n-times-2 cell array, the second column specifies
%     a label for that column, which will be the first row of the export.
%
%     If 'use_columns' is a n-times-3 cell array, the third column specifies
%     a format string that column which can be used for 'sprintf' for example.
%     All values except for the first row are converted to strings using this
%     format string.
%
%   See also vsdp_benchmark.
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)

narginchk (2, 5);

fmt = validatestring (fmt, {'cell', 'csv', 'html', 'latex'});
if (nargin < 3)
  out_file = [];
else
  if (exist (out_file, 'file') == 2)
    error ('VSDP_BENCHMARK:export:outputFileExists', ...
      'export: File ''%s'' already exists.  Choose another name.', out_file);
  end
end
if (nargin < 4)
  % Use all data, if no filter was applied.
  filter = obj.filter ();
end
if (nargin < 5)
  % Use default columns with LaTeX labels.
  use_columns = { ...
    'lib',      'Library', '%s';
    'name',     'Name',    '%s';
    'file',     'File',    '%s';
    'm',        '$m$',     '%d';
    'n',        '$n$',     '%d';
    'K_f',      '$K_f$',   '%d';
    'K_l',      '$K_l$',   '%d';
    'K_q',      '$K_q$',   '%d';
    'K_s',      '$K_s$',   '%d';
    'sname',    'Solver',  '%s';
    'fp',       '$f_p$',   '%e';
    'fd',       '$f_d$',   '%e';
    'ts',       '$t_s$',   '%e';
    'fL',       '$\underline{f_p}$',   '%e';
    'tL',       '$\underline{t}$',     '%e';
    'tL/ts',    '$\underline{t}/t_s$', '%e';
    'fU',       '$\overline{f_d}$',    '%e';
    'tU',       '$\overline{t}$',      '%e';
    'tU/ts',    '$\overline{t}/t_s$',  '%e';
    'fU-fL',    '$\overline{f_d} - \underline{f_p}$',     '%e';
    'mu_fU_fL', '$\mu(\overline{f_d}, \underline{f_p})$', '%e'};
end

cdata = gather_data (obj, filter, use_columns);

switch (fmt)
  case 'cell'
  case 'csv'
  case 'html'
  case 'latex'
end

if (nargout > 0)
  output = cdata;
end

end


function output = gather_data (obj, filter, use_columns)
% GATHER_DATA  of all requested test cases.

% Gather the cached computed solutions.
solution_values = {obj.BENCHMARK(filter.benchmark).values};
% Counts how many solutions for a particular test case exist.
number_of_solutions = cellfun (@length, solution_values);
% Counts how many rows for a particular test case should exist (at least one).
rows_for_solutions  = max (1, number_of_solutions);

% Create right half of the big table 'output'.
chead = {'sname', 'fp', 'fd', 'ts', 'fL', 'tL', 'fU', 'tU'};
output = cell (sum (rows_for_solutions) + 1, length (chead));  % Preallocate.
output(1,:) = chead;
% Write the solutions in the corresponding row with offset.
offset = cumsum ([1, rows_for_solutions(1:end-1)]);
for i = 1:length(number_of_solutions)
  if (number_of_solutions(i) > 0)
    sols = struct2cell (solution_values{i});
    sols = reshape (sols, size (sols, 1), size (sols, 3))';
    output((1:number_of_solutions(i)) + offset(i),:) = sols;
  end
end

% Compute the index 'rep_idx' to multiply the rows according to the number
% of different solutions.
rep_idx = cellfun (@(i,j) repmat (i, j, 1), num2cell (filter.benchmark), ...
  num2cell (rows_for_solutions), 'UniformOutput', false);
rep_idx = vertcat (rep_idx{:});

% Create left half of the big table 'output' and merge horizontally.
chead = {'lib', 'name' 'file', 'm', 'n', 'K_f', 'K_l', 'K_q', 'K_s'};
output = [[chead; ...
  {obj.BENCHMARK(rep_idx).lib}', ...
  {obj.BENCHMARK(rep_idx).name}', ...
  {obj.BENCHMARK(rep_idx).file}', ...
  {obj.BENCHMARK(rep_idx).m}', ...
  {obj.BENCHMARK(rep_idx).n}', ...
  {obj.BENCHMARK(rep_idx).K_f}', ...
  {obj.BENCHMARK(rep_idx).K_l}', ...
  {obj.BENCHMARK(rep_idx).K_q}', ...
  {obj.BENCHMARK(rep_idx).K_s}'], ...
  output];

% The big table 'output' is now filtered for 'lib' and 'name'.  Apply filter
% for solvers 'sname'.
solver_col = output(2:end,get_col_num(output,'sname'));
% Fill empty cells with empty char array.
idx = cellfun (@(x) isempty(x), solver_col);
solver_col(idx) = {''};
% Get indices of the intersection of filtered and present solvers.
[~, match_idx] = intersect (solver_col, {obj.SOLVER(filter.solver).name});
idx(match_idx) = true;
% Finally filter the rows.
output([false; ~idx], :) = [];

% Append additional dependend columns, created from the basis data, and strip
% not requested columns.
final_output = cell (size (output, 1), size (use_columns, 1));
for i = 1:length(use_columns(:,1))
  if (~any (strcmp (use_columns{i,1}, output(1,:))))
    final_output(:,i) = append_row (output, use_columns{i,1});
  else
    final_output(:,i) = output(:,get_col_num (output, use_columns{i,1}));
  end
end
output = final_output;
end


function new_row = append_row (output, col)
% APPEND_COLUMN  Compute and append a dependend column to a fixed column table.
%

new_row = cell (size (output, 1), 1);

% Compute accurracy mu <https://vsdp.github.io/references.html#Jansson2006>,
% that is 'mu_<op1>_<op2>'.
if (strncmp (col, 'mu_', 3))
  try
    % Extract operands.
    cols = strsplit (col(4:end), '_');
    a = [output{2:end,get_col_num (output, cols{1})}];
    b = [output{2:end,get_col_num (output, cols{2})}];
    acc_mu = @(a, b) (a - b) ./ max (1, (abs (a) + abs (b)) ./ 2);
    % Perform division for non-empty values.
    idx = cellfun (@(x) ~isempty(x), output(:,get_col_num (output, cols{1})));
    new_row = cell (size (output, 1), 1);
    new_row(idx) = [{col}, num2cell(acc_mu (a, b))];
  catch
    warning ('VSDP_BENCHMARK:export:errorComputingColumn', ...
      'export: Error computing column ''%s'', ignored.', col);
  end
elseif ((any (col == '/')) || (any (col == '-')))  % '<op1><op><op2>'
  % Determine operation.
  if (any (col == '/'))
    op = '/';
    fop = @rdivide;
  else
    op = '-';
    fop = @minus;
  end
  % Extract operands.
  cols = strsplit (col, op);
  cols{1} = get_col_num (output, cols{1});
  cols{2} = get_col_num (output, cols{2});
  try
    % Perform operation for non-empty values.
    idx = cellfun (@(x) ~isempty(x), output(:,cols{1}));
    
    new_row(idx) = [{col}, ...
      num2cell(fop ([output{2:end,cols{1}}], [output{2:end,cols{2}}]))];
  catch
    warning ('VSDP_BENCHMARK:export:errorComputingColumn', ...
      'export: Error computing column ''%s'', ignored.', col);
  end
else
  warning ('VSDP_BENCHMARK:export:nonExistingColumn', ...
    'export: Ignore column ''%s''.', col);
  new_row = [];  
end
end


function num = get_col_num (output, col)
% GET_COL_NUM  Get the number of a column of a fixed column order table.
num = find (strcmp (col, output (1,:)));
end
