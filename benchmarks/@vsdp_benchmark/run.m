function run (obj, path, filename, file, tfile)
% RUN  Run the VSDP benchmark.
%
%   obj.run (path, filename, file, tfile)
%      A benchmark test will be performed on problems found on path 'path'.
%      The results (optimal values ,rigorous lower and upper bounds and times)
%      are saved in the textfiles 'filename' reps. 'filename'_timings or
%      in the files given by handels 'file' resp. 'tfile'. Some Tex sequences
%      for tables in Latex will be created.
%
%      path:         path of test problems
%      filename:     name of the file for the results
%      file, tfile:  file handels for results if not given by 'filename'
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)

if nargin<3 || isempty(file) || file<=0
  file = fopen(filename,'w');
  if file==0
    error('VSDP:BENCHMARK','Could not open the file %s',filename);
  end
end

if nargin<4 || isempty(tfile) || tfile<=0
  tfilename = [filename(1:end-4),'_timings.txt'];
  tfile = fopen(tfilename,'w');
  if tfile==0
    error('VSDP:BENCHMARK','Could not open the file %s',tfilename);
  end
end

% root contains files and sub-folders in path folder
root = dir(path);

if length(root)==2  % empty folder
  warning('VSDP:BENCHMARK',['"',path,'" is empty']);
  return;
elseif (length(root)>2)  % if folder: exclude './' and '../' in root
  root([1 2]) = [];
end
% folders first than files
[~,idx] = sort([root(:).isdir],'descend');
root = root(idx);

% write table head if test subdirectory reached
if ~root(1).isdir
  % table for results
  fprintf(file,'\\begin{center}\n');
  fprintf(file,'\\begin{table} {Test Problems from %s} \\\\[1ex]',path);
  fprintf(file,'\n\\begin{tiny}\n');
  fprintf(file,['\\begin{tabular}[b]{|l|c|c|c|c|c|c|l|} \\hline',...
    '& & & & & & & \\\\[-2ex]\n']);
  fprintf(file,['\\textbf{Problem} & $p^*$ & $d^*$ & $\\bar{d}$ & ',...
    '$\\underline{p}$ & $\\mu(p^*,d^*)$ & $\\mu(',...
    '\\underline{p},\\bar{d})$ & Solver \\\\ \\hline\n']);
  % table for timings
  fprintf(tfile,'\\begin{center}\n');
  fprintf(tfile,'\\begin{table} {Timings for %s} \\\\[1ex]',path);
  fprintf(tfile,'\n\\begin{tiny}\n');
  fprintf(tfile,['\\begin{tabular}[b]{|l|c|c|c|l|} \\hline',...
    'Problem & $t_s$ & $t_u$ & $t_l$ & ',...
    'Solver \\\\  \\hline\n']);
end

for j = 1:length(root)  % start from third entry to exclude './' and '../' in mr
  if root(j).isdir
    newpath = fullfile(path,root(j).name);
    benchmark(newpath,'',file,tfile);
  else
    % cleaning/preparing memory
    clear A b c K x0 y0 z0 objt info;
    pack;
    % go the next problem
    probname = root(j).name;
    fullname = fullfile(path,probname);
    try
      % load matlab data
      if length(probname)>=5 && strcmpi(fullname(end-3:end),'.mat')
        load(fullname);
        ww = whos;
        for jw=1:length(ww)
          if strcmp(ww(jw).name,'At')
            A = At; clear At;
          end
          if strcmp(ww(jw).name,'Amatrix')
            A = Amatrix; clear Amatrix;
          end
          if strcmp(ww(jw).name,'C')
            c = C; clear C ww;
            break;
          end
        end
        % [A,b,c] = sedumi2vsdp(A,b,c,K);
        % load sparse sdpa data
      elseif strcmpi(probname(end-min(4,length(probname)-1):end),'dat-s')
        [A,b,c,K] = sdpa2vsdp(fullname);
        % load nothing, continue to next file
      elseif strcmpi(probname(end-min(2,length(probname)-1):end),'SIF')
        [A,b,c,K] = mps2vsdp(fullname);
      else
        warning('VSDP:BENCHMARK','not supported file found');
        continue;
      end
    catch loaderror
      msgstr = loaderror.message;
      msglen = min(length(msgstr),20);
      msgstr = msgstr(1:msglen);
      fprintf(file,['%s & \\multicolumn{6}{|l|}{',...
        msgstr,'} & \\\\ \\hline\n'],...
        probname);
      fprintf(tfile,['%s & \\multicolumn{3}{|l|}{  & ',...
        msgstr,'} & \\\\ \\hline\n'],...
        probname);
      continue;
    end
    % some preprocessing of probleme names
    sidx = (probname=='_');
    probname(sidx) = '';
    sidx = find(probname=='.') - 1;
    if isempty(sidx)
      sidx = length(probname);
    end
    probname = probname(1:min(sidx,12));
    %try to solve the problem
    for i = 1:length(obj.SOLVER)
      opts.SOLVER = obj.SOLVER{i};
      % try to solve with an approximate solver
      try
        tic; [objt,x0,y0,z0] = mysdps(A,b,c,K,[],[],[],opts); ts = toc;
        ps = objt(1); ds = objt(2);
        fprintf(file,'%s & %1.8e & %1.8e & ',probname,ps,ds);
      catch solvererror
        msgstr = solvererror.message;
        msglen = min(length(msgstr),20);
        msgstr = msgstr(1:msglen);
        fprintf(file,['%s & \\multicolumn{6}{|l|}{',...
          msgstr,'} & %s\\\\ \\hline\n'],...
          probname,obj.SOLVER{i});
        fprintf(tfile,['%s & \\multicolumn{3}{|l|}{',...
          msgstr,'} & %s\\\\ \\hline\n'],...
          probname,obj.SOLVER{i});
        continue;
      end
      % try to find upper bound
      try
        tic; fU = vsdpup(A,b,c,K,x0,y0,z0,[],opts); tu = toc;
        fprintf(file,'%1.8e & ',fU);
      catch vsdpuperror
        msgstr = vsdpuperror.message;
        msglen = min(length(msgstr),20);
        msgstr = msgstr(1:msglen);
        fprintf(file,[' & \\multicolumn{4}{|l|}{',...
          msgstr,'} & %s\\\\ \\hline\n'],...
          'VSDP:VSDPUP');
        fprintf(tfile,[' & \\multicolumn{2}{|l|}{',...
          msgstr,'} & %s\\\\ \\hline\n'],...
          'VSDP:VSDPUP');
        continue;
      end
      % try to find lower bound
      try
        tic; fL = vsdplow(A,b,c,K,x0,y0,z0,[],opts); tl = toc;
        fprintf(file,'%1.8e & ',fL);
      catch dummy
        msgstr = dummy.message;
        msglen = min(length(msgstr),20);
        msgstr = msgstr(1:msglen);
        fprintf(file,[' & \\multicolumn{1}{|l|}{',...
          msgstr,'} & %s\\\\ \\hline\n'],...
          'VSDP:VSDPLOW');
        fprintf(tfile,[' & \\multicolumn{1}{|l|}{',...
          msgstr,'} & %s\\\\ \\hline\n'],...
          'VSDP:VSDPLOW');
        continue;
      end
      mup = (ps - ds)/max(1,(abs(ps) + abs(ds))/2);
      muv = (fU - fL)/max(1,(abs(fL) + abs(fU))/2);
      % write rest results
      fprintf(file,'%1.8e & %1.8e & %s \\\\ \\hline\n', ...
        mup, muv, obj.SOLVER{i});
      fprintf(tfile,['%s & %6.3d & %6.3d & %6.3d & %s \\\\ ', ...
        '\\hline\n'],probname,ts,tu,tl,obj.SOLVER{i});
      clear objt x0 y0 z0; pack;
    end
  end
end

% write table closing sequences
if ~root(1).isdir
  % end of results table
  fprintf(file,'\\end{tabular}\n');
  fprintf(file,'\\end{tiny}\n');
  fprintf(file,'\\end{table}\n');
  fprintf(file,'\\end{center}\n\n');
  % end of timings table
  fprintf(tfile,'\\end{tabular}\n');
  fprintf(tfile,'\\end{tiny}\n');
  fprintf(tfile,'\\end{table}\n');
  fprintf(tfile,'\\end{center}\n');
end

end
