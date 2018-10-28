function output = export (obj, fmt, out_file, filter, use_columns, stat_funs)
% EXPORT  Export the data of the VSDP benchmark object 'obj'.
%
%   output = obj.export (fmt)  Export all available data to the destination
%     format 'fmt' which is one of 'cell', 'csv', 'html', 'markdown', or
%     'latex'.  In case of 'fmt' = 'cell', the variable 'output' contains cell
%     array with all available data with original data type.  Otherwise a
%     formatted string in the respective format is returned.
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
%   obj.export (__, __, __, __, stat_funs)  Optionally, specify a cell vector
%     of statistical function names like 'min', 'max', 'mean', ... that shound
%     be applied for each column.  Note, that non-numerical columns might
%     result in errors or nonsensual data.  Ensure numerical columns using the
%     'use_columns' parameter.
%
%   See also vsdp_benchmark.
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)

narginchk (2, 6);

fmt = validatestring (fmt, {'cell', 'csv', 'html', 'markdown', 'latex'});
if (nargin < 3)
  out_file = [];
  if (nargout == 0)
    error ('VSDP_BENCHMARK:export:nothingToDo', ...
      'export: Please specify an output file or variable.');
  end
else
  if (~isempty (out_file) && (exist (out_file, 'file') == 2))
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

% Make a statistic of cdata.
if (nargin > 5)
  cdata = to_statistic (cdata, stat_funs);
  % Extend header.
  new_header = {'', '', '%s'};
  use_columns = [new_header(1,1:size (use_columns, 2)); use_columns];
end

% Replace column heads by labels, for some formats.
switch (fmt)
  case {'html', 'markdown', 'latex'}
    if (size (use_columns, 2) > 1)
      cdata(1,:) = use_columns(:,2);
    end
end

% Format cell content to string, for some formats.
switch (fmt)
  case {'csv', 'html', 'markdown', 'latex'}
    if (size (use_columns, 2) == 3)
      for i = 1:size(cdata, 2)
        cdata(2:end,i) = cellfun (@(x) sprintf (use_columns{i,3}, x), ...
          cdata(2:end,i), 'UniformOutput', false);
      end
    else
      cdata = cellfun (@num2str, cdata, 'UniformOutput', false);
    end
end

% Save 'cdata' to 'out_file' if given.
switch (fmt)
  case 'cell'
    if (~isempty (out_file))
      save (out_file, 'cdata', '-v7');
    end
  case {'csv', 'html', 'markdown', 'latex'}
    cdata = eval (['to_', fmt ,'(cdata);']);
    if (~isempty (out_file))
      f = fopen (out_file, "w");
      fprintf (f, "%s", cdata);
      fclose (f);
    end
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
wanted_solvers = {obj.SOLVER(filter.solver).name};
for i = 1:length(wanted_solvers)
  idx = idx | cellfun (@(x) isequal(x, wanted_solvers{i}), solver_col);
end
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


function cdata_out = to_statistic (cdata, stat_funs)
% TO_STATISTIC  Generate a statistic of 'cdata'.

cdata_out = cell (length (stat_funs) + 1, size (cdata, 2) + 1);
% Copy head line.
cdata_out(1,2:end) = cdata(1,:);
% Add statistic function names for each row.
cdata_out(2:end,1) = stat_funs;

for i = 1:size (cdata, 2)
  for j = 1:length (stat_funs)
    dvec = [cdata{2:end,i}];
    cdata_out{j + 1, i + 1} = eval (sprintf ('%s(dvec);', stat_funs{j}));
  end
end
end


function str = to_csv (cdata)
% TO_CSV  Export data to comma seperated values (CSV).
for i = 1:size (cdata, 1)
  cdata{i,1} = strjoin (cdata(i,:), ',');
end
cdata = cdata(:,1);
str = strjoin (cdata, '\n');
end


function str = to_html (cdata)
% TO_HTML  Export 'cdata' to rich HTML markup (MathJax, jQuery, dataTables).

thead = sprintf ('  <th>%s</th>\n', strjoin (cdata(1,:), '</th>\n  <th>'));
thead = sprintf ('<thead>\n<tr>\n%s</tr>\n</thead>\n', thead);
for i = 2:size (cdata, 1)
  cdata{i,1} = sprintf ('  <td>%s</td>\n', strjoin (cdata(i,:), ...
    '</td>\n  <td>'));
end
cdata = cdata(2:end,1);
str = sprintf ('<tr>\n%s</tr>\n', strjoin (cdata, '</tr>\n<tr>\n'));
str = sprintf ('<tbody>\n%s</tbody>\n', str);
str = sprintf ( ...
  '<table id="main_tab" class="display" style="width:100%%">\n%s%s</table>\n', ...
  thead, str);

header = strjoin ({ ...
  '<!DOCTYPE html>', ...
  '<html>', ...
  '<head>', ...
  '<title>VSDP Benchmark Results</title>', ...
  '<meta charset=''UTF-8''>', ...
  '<link rel="stylesheet"', ...
  ' href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.min.css">', ...
  '<link rel="stylesheet"', ...
  ' href="https://cdn.datatables.net/select/1.2.7/css/select.dataTables.min.css">', ...
  '<script type="text/javascript"', ...
  ' src="https://code.jquery.com/jquery-3.3.1.js"></script>', ...
  '<script type="text/javascript"', ...
  ' src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js">', ...
  '</script>', ...
  '<script type="text/javascript"', ...
  ' src="https://cdn.datatables.net/select/1.2.7/js/dataTables.select.min.js">', ...
  '</script>', ...
  '<script type="text/x-mathjax-config">', ...
    'MathJax.Hub.Config({', ...
    'tex2jax: { inlineMath: [[''$'',''$''], [''\\('',''\\)'']] },', ...
    '});', ...
  '</script>', ...
  '<script type="text/javascript" async ', ...
  'src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML">', ...
  '</script>', ...
  '</head>', ...
  '<body>'}, '\n');
footer = strjoin ({ ...
  '<script type=''text/javascript''>$(document).ready( function () {', ...
  '$(''#main_tab'').DataTable( {', ...
  '  select: true,', ...
  '  "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]]', ...
  '  } );', ...
  '} );', ...
  '</script>', ...
  '</body>', ...
  '</html>'}, '\n');

str = sprintf ('%s\n%s%s\n', header, str, footer);
end


function str = to_markdown (cdata)
% TO_MARKDOWN  Export data to Markdown format.
for i = 1:size (cdata, 1)
  cdata{i,1} = strjoin (cdata(i,:), ',');
end
cdata = cdata(:,1);
str = strjoin (cdata, '\n');
end


function str = to_latex (cdata)
% TO_LATEX  Export 'cdata' to LaTeX markup (longtable environment).

thead = strjoin (cdata(1,:), '\n& ');
thead = sprintf ('{%s}\n\\toprule\n%s \\\\\n\\toprule\n', ...
  repmat('c', 1, size (cdata(1,:), 2)), thead);
for i = 2:size (cdata, 1)
  cdata{i,1} = sprintf ('%s \\\\', strjoin (cdata(i,:), '\n& '));
end
cdata = cdata(2:end,1);
str = sprintf ('%s\n', strjoin (cdata, '\n'));

header = strjoin ({ ...
  '\documentclass{article}', ...
  '\usepackage{booktabs}', ...
  '\usepackage{longtable}', ...
  '\usepackage{mathtools}', ...
  '', ...
  '\begin{document}', ...
  '\begin{longtable}'}, '\n');
footer = strjoin ({ ...
  '\bottomrule', ...
  '\end{longtable}', ...
  '\end{document}'}, '\n');

str = sprintf ('%s%s%s%s', header, thead, str, footer);
end
