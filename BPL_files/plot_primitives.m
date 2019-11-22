%
% Plot primitives that the model learns
% - primitives are stored in lib.shape.mu of the lib object 
% - primitives are defined by 5 points. Each row of 
% lib.shape.mu is a 1x10 array with values 1:5 denoting
% the x-coordinates, values 6:10 denoting the y-coordinates
%
% Run this from inside the BPL folder

lib = loadlib; % loadlib is defined in BPL/loadlib.m

N = 100; % number of primitives

xhi = max(max(lib.shape.mu(:,1:5)));
xlo = min(min(lib.shape.mu(:,1:5)));
ylo = min(min(lib.shape.mu(:,6:end)));
yhi = max(max(lib.shape.mu(:,6:end)));

for i=1:N
   prim = lib.shape.mu(i,:);
   subplot(sqrt(N),sqrt(N),i)
   hold on;
   plot(prim(1:1:5), prim(6:1:end),'-o')
   scatter(prim(1), prim(6),'r')
   xlim([xlo xhi])
   ylim([ylo yhi])
end