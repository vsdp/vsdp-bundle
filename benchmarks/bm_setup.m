function bm_setup ()
% BM_SETUP  Sets up all required solvers for VSDP's benchmark.
%
%   See also vsdp.solve.
%

OLD_DIR = cd ('..');

% Determine paths.
ROOT_DIR = pwd ();
SOLVER_DIR = fullfile (ROOT_DIR, 'solver');

INTLAB_DIR = fullfile (SOLVER_DIR, 'intlab');
if (exist ('isintval', 'file') ~= 2)
  if (isdir (INTLAB_DIR))
    cd (INTLAB_DIR);
    startintlab ();
  else
    error ('VSDP:bm_setup:noINTLAB', ...
      ['bm_setup: INTLAB is required to run VSDP.  Get a recent version ', ...
      'from  http://www.ti3.tuhh.de/rump/intlab']);
  end
end

SDPT3_DIR = fullfile (SOLVER_DIR, 'sdpt3');
if ((exist ('sqlp', 'file') ~= 2) && isdir (SDPT3_DIR))
  cd (SDPT3_DIR);
  install_sdpt3 ();
end

SEDUMI_DIR = fullfile (SOLVER_DIR, 'sedumi');
if ((exist ('sedumi', 'file') ~= 2) && isdir (SEDUMI_DIR))
  cd (SEDUMI_DIR);
  install_sedumi ();
end

SDPA_DIR = fullfile (SOLVER_DIR, 'sdpa');
if ((exist ('sdpam', 'file') ~= 2) && isdir (SDPA_DIR))
  addpath (fullfile (SDPA_DIR, 'mex'));
end

CSDP_DIR = fullfile (SOLVER_DIR, 'csdp');
if ((exist ('csdp', 'file') ~= 2) && isdir (CSDP_DIR))
  addpath (fullfile (CSDP_DIR, 'matlab'));
end

MOSEK_DIR = fullfile (SOLVER_DIR, 'mosek');
if ((exist ('mosekopt', 'file') ~= 3) && isdir (MOSEK_DIR))
  addpath ((fullfile (MOSEK_DIR, '8', 'toolbox', 'r2014aom')));
end

VSDP_DIR = fullfile (ROOT_DIR, 'vsdp', '2018');
cd (VSDP_DIR);
install_vsdp ();

cd (OLD_DIR);
end
