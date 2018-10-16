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

use_columns = {'lib', 'name', 'file', 'm', 'n', 'K_f', 'K_l', 'K_q', 'K_s', ...
  'sname', 'fp', 'fd', 'ts', 'fL', 'tL', 'fU', 'tU'; ...
  '%s', '%s', '%s', '%d', '%d', '%d', '%d', '%d', '%d', ...
  '%s', '%e', '%e', '%e', '%e', '%e', '%e', '%e'};
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
output = cell (length (filter.benchmark) + 1, length (use_columns));
output(1,:) = use_columns(1,:);
% for j = filter.benchmark
%   output{j,1} = obj.BENCHMARK(j).lib;
%   output{j,2} = obj.BENCHMARK(j).name;
%   %output{j,3} = obj.BENCHMARK(j).lib;
%   for i = filter.solver
%   end
% end
end
