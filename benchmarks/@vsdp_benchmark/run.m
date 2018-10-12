function run (obj)
% RUN  Run the VSDP benchmark.
%
%   obj.run ()
%      A benchmark test will be performed on problems found on path 'path'.
%      The results (optimal values ,rigorous lower and upper bounds and times)
%      are saved in the textfiles 'filename' reps. 'filename'_timings or
%      in the files given by handels 'file' resp. 'tfile'. Some Tex sequences
%      for tables in Latex will be created.
%

% Copyright 2004-2018 Christian Jansson (jansson@tuhh.de)


file = 1;
tfile = 1;

for j = 1:length(obj.BENCHMARK)
  fprintf ('%s/%s (%3d/%3d)\n', obj.BENCHMARK(j).lib, obj.BENCHMARK(j).name, ...
    j, length(obj.BENCHMARK));
  try
    [fpath, fname, fext] = fileparts (obj.BENCHMARK(j).file);
    
    % Extract *.gz-archive if necessary.
    if (strcmp (fext, '.gz'))
      % Copy file to temporary directory.
      tmp_file = fullfile (obj.TMP_DIR, [fname, fext]);
      copyfile (obj.BENCHMARK(j).file, tmp_file);
      % Extract.
      gunzip (tmp_file);
      % Update data for working copy.
      tmp_file((end - length ('.gz') + 1):end) = [];
      [fpath, fname, fext] = fileparts (tmp_file);
    end
    
    % Import data to VSDP object 'obj' depending on the file type.
    dfile = fullfile (fpath, [fname, fext]);
    vsdp_obj = [];
    switch (fext)
      case '.mat'  % MAT-file.
        load (dfile);
        sprintf('delete (''%s*'');\n', tmp_file);
        if (exist ('A', 'var') == 1)
          vsdp_obj = vsdp (A, b, c, K);
          clear ('A', 'b', 'c', 'K');
        else
          vsdp_obj = vsdp (At, b, c, K);
          clear ('At', 'b', 'c', 'K');
        end
      case 'dat-s'  % Sparse SDPA data.
        obj = vsdp.from_sdpa_file (dfile);
      case 'SIF'
        obj = vsdp.from_mps_file (dfile);
      otherwise
        warning ('VSDP_BENCHMARK:run:unsupportedData', ...
          'run: Unsupported file ''%s''.', obj.BENCHMARK(j).file);
        continue;
    end
    
    for i = 1:length(obj.SOLVER)
      % Make a clean copy and set the solver to be used.
      vsdp_obj = vsdp (vsdp_obj);
      vsdp_obj.options.SOLVER = obj.SOLVER(i).name;
      
      ta = toc;
      [ps, ds] = objt(2);
      fprintf(file,'%s & %1.8e & %1.8e & ',obj.BENCHMARK(j).name,ps,ds);
      
      
      tic; fU = vsdpup(A,b,c,K,x0,y0,z0,[],opts); tu = toc;
      fprintf(file,'%1.8e & ',fU);
      tic; fL = vsdplow(A,b,c,K,x0,y0,z0,[],opts); tl = toc;
      fprintf(file,'%1.8e & ',fL);
      mup = (ps - ds)/max(1,(abs(ps) + abs(ds))/2);
      muv = (fU - fL)/max(1,(abs(fL) + abs(fU))/2);
      % write rest results
      fprintf(file,'%1.8e & %1.8e & %s \\\\ \\hline\n', ...
        mup, muv, obj.SOLVER(i).name);
      fprintf(tfile,['%s & %6.3d & %6.3d & %6.3d & %s \\\\ ', ...
        '\\hline\n'],obj.BENCHMARK(j).name,ta,tu,tl,obj.SOLVER(i).name);
      clear objt x0 y0 z0; pack;
    end
  catch err
    fprintf (2, '\n\n%s\n\n', err.message);
    continue;
  end
end
end
