function output = export (obj, fmt, filter, use_columns, out_file_name)
% EXPORT  Export the data of the VSDP benchmark object 'obj'.
%
%   Detailed explanation goes here

narginchk (2, 5);

fmt = validatestring (fmt, {'cell', 'csv', 'html', 'latex'});
if (nargin < 3)
  filter = [];
end
if (nargin < 4)
  use_columns = [];
end
if (nargin < 5)
  out_file = [];
end

use_columns = { ...
  'lib',   '%s', '';
  'name',  '%s', '';
  'file',  '%s', '';
  'm',     '%d', '';
  'n',     '%d', '';
  'K_f',   '%d', '';
  'K_l',   '%d', '';
  'K_q',   '%d', '';
  'K_s',   '%d', '';
  'sname', '%s', '';
  'fp',    '%e', '';
  'fd',    '%e', '';
  'ts',    '%e', '';
  'fL',    '%e', '';
  'tL',    '%e', '';
  'tL/ts', '%e', '';
  'fU',    '%e', '';
  'tU',    '%e', '';
  'tU/ts', '%e', '';};
output = gather_data (obj, filter, use_columns);

switch (fmt)
  case 'cell'
  case 'csv'
  case 'html'
  case 'latex'
end

end


function output = gather_data (obj, filter, use_columns)
if (isempty (filter))
  filter = obj.filter ();
end

solution_values = {obj.BENCHMARK(filter.benchmark).values};
number_of_solutions = cellfun (@length, solution_values);
rows_for_solutions  = max (1, number_of_solutions);

chead = {'sname', 'fp', 'fd', 'ts', 'fL', 'tL', 'fU', 'tU'};
sol_cell = cell (sum (rows_for_solutions) + 1, length (chead));
sol_cell(1,:) = chead;
offset = cumsum ([1, rows_for_solutions(1:end-1)]);
for i = 1:length(number_of_solutions)
  if (number_of_solutions(i) > 0)
    sols = struct2cell (solution_values{i});
    sols = reshape (sols, size (sols, 1), size (sols, 3))';
    sol_cell((1:number_of_solutions(i)) + offset(i),:) = sols;
  end
end

rep_idx = cellfun (@(i,j) repmat (i, j, 1), num2cell (filter.benchmark), ...
  num2cell (rows_for_solutions), 'UniformOutput', false);
rep_idx = vertcat (rep_idx{:});

chead = {'lib', 'name' 'file', 'm', 'n', 'K_f', 'K_l', 'K_q', 'K_s'};
output = cell (length (rep_idx) + 1, length (chead));
output(1,:) = chead;
output(2:end,1) = {obj.BENCHMARK(rep_idx).lib};
output(2:end,2) = {obj.BENCHMARK(rep_idx).name};
output(2:end,3) = {obj.BENCHMARK(rep_idx).file};
output(2:end,4) = {obj.BENCHMARK(rep_idx).m};
output(2:end,5) = {obj.BENCHMARK(rep_idx).n};
output(2:end,6) = {obj.BENCHMARK(rep_idx).K_f};
output(2:end,7) = {obj.BENCHMARK(rep_idx).K_l};
output(2:end,8) = {obj.BENCHMARK(rep_idx).K_q};
output(2:end,9) = {obj.BENCHMARK(rep_idx).K_s};

output = [output, sol_cell];

end
