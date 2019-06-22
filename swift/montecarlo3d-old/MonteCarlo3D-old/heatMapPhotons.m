%% MATLAB script to read the data produced by the software
%% bin it, and plot it.

a=load('/tmp/stats-side.txt');

dx = 0.02;
range  = -3:dx:3;
b=zeros(size(range,2),size(range,2),size(range,2));

pos = discretize(a(:,1:3),range);
disc = cat(2,pos,a(:,4));
   
for l=1:size(disc,1)
   i = disc(l,1);
   j = disc(l,2);
   k = disc(l,3);
   w = disc(l,4);
   
   if ~(isnan(i) || isnan(j) || isnan(k))
        b(i,j,k) = b(i,j,k) + w;
   end
end


%% Show data
proj3 = sum(b,3);
proj3 = proj3 ./ max(max(proj3)) / (dx*dx);

figure(1);imshow(log10(proj3+1));colormap jet;
figure(2);imshow(proj3);colormap jet;


