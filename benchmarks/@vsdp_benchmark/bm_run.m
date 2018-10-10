function [bm_list, options] = bm_run ()

%bm_setup ()

[bm_list, options] = bm_collector ();

done = 0;
for i = 1:length(bm_list)
  try
    eval (bm_list(i).setup);
  catch
    fprintf ('FAIL %3d\n', i);
    continue;
  end
  fprintf ('Done %3d\n', i);
  done = done + 1;
end

fprintf ('\nDone %3d/%3d\n', done, length(bm_list));

end
