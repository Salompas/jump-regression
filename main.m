%% Clear workspace
addpath('scripts/'); % path to scripts
clearWorkspace;

%% Parameters
n = 77; % returns per day
T = 175110/(n+1); % number of days
delta_n = 1/n;
alpha = 4;
kn = 11;

%% Load Data for SPY
filename = 'data/SPY_5min.dat';
raw = load(filename);

%% SPY: Extract Returns, BV, TOD, Jump CUT, Diffusive Returns and Jump Returns
[ret,dates] = getReturnAndDate(raw(:,1:2),raw(:,3),n,T);
BV = getBV(ret,n,T);
tod = getTOD(ret,n,T);
cut = getCUT(alpha,tod,BV,delta_n);
[r_c,r_d] = separateReturns(ret,cut);

%% Load Stock Data
stocks = {'AIG_5min.dat','BLK_5min.dat','CB_5min.dat','C_5min.dat','GNTX_5min.dat','MET_5min.dat','MMC_5min.dat','MS_5min.dat','PNC_5min.dat','STT_5min.dat','TRV_5min.dat'}';
sraw = load('data/AIG_5min.dat');

%% STOCK: Extract Returns, BV, TOD, Jump CUT, Diffusive Returns and Jump Returns
[sret,~] = getReturnAndDate(sraw(:,1:2),sraw(:,3),n,T);
sBV = getBV(sret,n,T);
stod = getTOD(sret,n,T);
scut = getCUT(alpha,stod,sBV,delta_n);
[sr_c,sr_d] = separateReturns(sret,scut);

%% Find Jump Location, Spot Covariances at Jumps and the Jump Beta
jump_loc = find(abs(ret) > cut);
[c,flag] = getSpotCov(sr_c,r_c,jump_loc,n,kn);
Q = getJumpCov(sret,ret,jump_loc);

nj = length(jump_loc); % number of jumps
[sigma,R] = getSpotVol(c,Q,nj);
[beta,beta_tilde] = jumpReg(sret,ret,Q,c,jump_loc,nj);
[CI_low, CI_up] = jumpRegCI(beta,0.05,ret,c,Q,jump_loc,nj,delta_n);