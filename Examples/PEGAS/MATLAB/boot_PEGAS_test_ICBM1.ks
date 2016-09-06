GLOBAL P_vName IS "PEGAS test ICBM".

GLOBAL P_seq IS LIST(-1.4, , , 139.0, , , , , 378.2).//remember to fill this!
//ignition (delay before release), booster jettison, fairings jettison, cutoff, separation, ullage, ignition, PEG activation, stage 2 maxT

GLOBAL P_pt IS LIST(  0.0000,  16.1000,  19.4000,  24.2000,  47.7942,  67.5047,  93.0940, 128.8000, 138.8000).
GLOBAL P_pp IS LIST(  0.0000,   0.0000,   3.3315,   3.3315,  14.9771,  27.5058,  43.5861,  59.1503,  59.1503).

GLOBAL P_umode IS .//remember to fill this!

TOGGLE AG10.

RUN pegas_loader.ks.