%% Setup.m - OpenRocket export
% OpenRocket: Simulations > Export data, comma separated, these columns in this order:
%   1 Time (s)          2 Mass (lb)          3 Longitudinal MOI (kg*m^2)
%   4 Rotational MOI    5 CP location (in)   6 CG location (in)
%   7 Thrust (N)        8 Drag coefficient   9 Mach number
%  10 Reference length (in)                 11 Reference area
%
% OpenRocket: Component analysis export (Coefs.csv), these columns in this order:
%   1 Mach number       2 CP fins (in)       3 CP nose cone (in)
%   4 CP rocket (in)    5 CNa rocket         6 CNa nose cone
%   7 CNa fins

D = readmatrix("MassProps.csv", CommentStyle="#");
[~, k] = unique(D(:,1));  D = D(k,:);        

t    = D(:,1);
m    = D(:,2) * 0.45359237;                 
Ilon = D(:,3);
Irol = D(:,4);
cp   = D(:,5) * 0.0254;                      
cg   = D(:,6) * 0.0254;
T    = D(:,7);
cd   = D(:,8);
mach = D(:,9);

b = find(T > 0, 1, "last") + 1;              

% 6DOF block
mp.mFull  = m(1);
mp.mEmpty = m(b);
mp.IFull  = diag([Irol(1) Ilon(1) Ilon(1)]);
mp.IEmpty = diag([Irol(b) Ilon(b) Ilon(b)]);

% Thrust vs time
mp.thrust = [t(1:b) T(1:b)];

% dm/dt = -thrust * propPerImpulse (propellant is used in proportion to impulse)
mp.propPerImpulse = (mp.mFull - mp.mEmpty) / trapz(t(1:b), T(1:b));

% CG
mp.cgEmpty = cg(b);
mp.cgProp  = (mp.mFull*cg(1) - mp.mEmpty*cg(b)) / (mp.mFull - mp.mEmpty);

% Aero tables vs Mach, motor off
c = t > t(b) & cp > 0 & mach > 0.05;
[mp.aero.mach, k] = unique(mach(c));
cdc = cd(c);  cpc = cp(c);
mp.aero.cd = cdc(k);
mp.aero.cp = cpc(k);                         
mp.aero.Lref = median(D(:,10)) * 0.0254;     
mp.aero.Aref = pi/4 * mp.aero.Lref^2;

% Coefs vs Mach (CP in m from nose tip, CNa per radian)
C = readmatrix("Coefs.csv", CommentStyle="#");

mp.coefs.mach    = C(:,1);
mp.coefs.cpFin   = C(:,2) * 0.0254;
mp.coefs.cpNose  = C(:,3) * 0.0254;
mp.coefs.cp      = C(:,4) * 0.0254;
mp.coefs.cna     = C(:,5);
mp.coefs.cnaNose = C(:,6);
mp.coefs.cnaFin  = C(:,7);
