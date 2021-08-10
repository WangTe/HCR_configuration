function[classOut]=calc_pid(dBZ,data,postProcess)

%data.VEL_CORR=abs(data.VEL_CORR);
data.VEL_CORR(data.elevation>0)=-data.VEL_CORR(data.elevation>0);

%   Membership functions for particle detection
% 1:Beta  2:Delta

plotMR=1;
plotMax=1;

w=[40 15 10 10 25];%w=[30 15 15 20 20];

% pid_hcr (number before post processing)
%  1 Rain (1)
%  2 Drizzle (2)
%  3 Supercooled drizzle (post-processing)
%  4 Cloud liquid (3)
%  5 Supercooled cloud liquid (post processing)
%  6 Mixed phase (4)
%  7 Snow (5)
%  8 Ice (6)

result=nan(6,size(data.LDR,1),size(data.LDR,2));

%  Membership functions for rain
m=nan(5,size(dBZ,1),size(dBZ,2));
m(1,:,:)=smf(dBZ,[3,5]);  % Rain
m(2,:,:)=zmf(data.LDR,[-27,-22]);
m(3,:,:)=trapmf(data.VEL_CORR,[2,3,6,8]);
m(4,:,:)=smf(data.WIDTH,[0.2,0.3]);
m(5,:,:)=smf(data.TEMP,[-1,2]);

result(1,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3)...
    +m(4,:,:)*w(4)+m(5,:,:)*w(5);

if plotMR
    plotMresult(data,m,result(1,:,:),'Rain');
end

%  Membership functions for drizzle
m=nan(5,size(dBZ,1),size(dBZ,2));
m(1,:,:)=trapmf(dBZ,[-17,-14,5,8]);
m(2,:,:)=zmf(data.LDR,[-27,-25]);
m(3,:,:)=trapmf(data.VEL_CORR,[0,0.5,1,2]);
m(4,:,:)=zmf(data.WIDTH,[0.1,0.2]);
m(5,:,:)=smf(data.TEMP,[-27,-25]);

result(2,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3)...
    +m(4,:,:)*w(4)+m(5,:,:)*w(5);

if plotMR
    plotMresult(data,m,result(2,:,:),'Drizzle');
end

%  Membership functions for cloud liquid
m=nan(5,size(dBZ,1),size(dBZ,2));
m(1,:,:)=zmf(dBZ,[-17,-14]);
m(2,:,:)=zmf(data.LDR,[-27,-25]);
m(3,:,:)=trapmf(data.VEL_CORR,[-6,-5,1,2]);
m(4,:,:)=zmf(data.WIDTH,[0.1,0.2]);
m(5,:,:)=smf(data.TEMP,[-2,2]);

result(3,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3)...
    +m(4,:,:)*w(4)+m(5,:,:)*w(5);

if plotMR
    plotMresult(data,m,result(3,:,:),'CloudLiquid');
end

%  Membership functions for mixed phase
m=nan(5,size(dBZ,1),size(dBZ,2));
m(1,:,:)=trapmf(dBZ,[-3,-1,10,15]);
m(2,:,:)=trapmf(data.LDR,[-20, -17,-8,-6]);
m(3,:,:)=trapmf(data.VEL_CORR,[0.5,1.0,3,4]);
m(4,:,:)=smf(data.WIDTH,[0.2, 0.3]);
m(5,:,:)=trapmf(data.TEMP,[-5,-3,2,4]);

result(4,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3)...
    +m(4,:,:)*w(4)+m(5,:,:)*w(5);

inoldr=find(isnan(data.LDR));
result(4,inoldr)=0;

if plotMR
    plotMresult(data,m,result(4,:,:),'MixedPhase');
end

%  Membership functions for snow
m=nan(5,size(dBZ,1),size(dBZ,2));
m(1,:,:)=trapmf(dBZ,[10,12,18,20]); % Snow
m(2,:,:)=trapmf(data.LDR,[-22,-18,-16, -14]);
m(3,:,:)=trapmf(data.VEL_CORR,[0.8,1.0,1.2,1.4]);
m(4,:,:)=smf(data.WIDTH,[0.2, 0.3]);
m(5,:,:)=zmf(data.TEMP,[-2,0]);

result(5,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3)...
    +m(4,:,:)*w(4)+m(5,:,:)*w(5);

if plotMR
    plotMresult(data,m,result(5,:,:),'Snow');
end

%  Membership functions for ice
m=nan(5,size(dBZ,1),size(dBZ,2));
m(1,:,:)=trapmf(dBZ,[-25,-20,5,10]);
m(2,:,:)=trapmf(data.LDR,[-25, -22,-15,-12]);
m(3,:,:)=trapmf(data.VEL_CORR,[-1,0,1,4]);
m(4,:,:)=zmf(data.WIDTH,[0.7,0.9]);
m(5,:,:)=zmf(data.TEMP,[-2,0]);

result(6,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3)...
    +m(4,:,:)*w(4)+m(5,:,:)*w(5);

if plotMR
    plotMresult(data,m,result(6,:,:),'Ice');
end

clear m

max1=squeeze(nanmax(result,[],1));
maxMat=repmat(max1,[1,1,6]);
maxMat=permute(maxMat,[3,1,2]);
resMinusMax=result-maxMat;
zerosMat=zeros(size(result));
zerosMat(resMinusMax==0)=1;

classOut=nan(size(data.LDR));

for ii=1:6
    testMat=squeeze(zerosMat(ii,:,:));
    classOut(isnan(classOut) & testMat==1)=ii;
end

if plotMax
    plotResMax(data,result,max1);
end

clearvars -except data classOut postProcess

%% Add supercooled
classOut(classOut==6)=8;
classOut(classOut==5)=7;
classOut(classOut==4)=6;
classOut(classOut==3)=4;

% Supercooled drizzle
classOut(classOut==2 & data.TEMP<0)=3;

% Supercooled cloud liquid
classOut(classOut==4 & data.TEMP<0)=5;

%% Post processing
if postProcess
    meltLayer=data.MELTING_LAYER;
    meltLayer(~isnan(meltLayer) & meltLayer<20)=10;
    meltLayer(~isnan(meltLayer) & meltLayer>=20)=20;
    
    % No frozen particles in strong downward motion
    classOut(meltLayer==10 & data.VEL_CORR>2.5 & ...
        (classOut==6 | classOut==7 | classOut==8))=1;
    
    % No frozen precipitation in warm region
    replaceMat=zeros(size(classOut));
    replaceMat(meltLayer==10 & (classOut==7 | classOut==8))=1;
    
    % Replace with closest warm pixel
    [oldR oldC]=find(~isnan(classOut) & replaceMat==0 & meltLayer==10);
    [addR addC]=find(replaceMat==1);
    idx = knnsearch([oldR oldC], [addR addC]);
    nearest_OldValue = classOut(sub2ind(size(classOut), oldR(idx), oldC(idx)));
    classOut(sub2ind(size(classOut), addR, addC))=nearest_OldValue;
    
    % Updrafts have no rain, no drizzle, and no snow.
    replaceMat=zeros(size(classOut));
    replaceMat(data.VEL_CORR<0 & (classOut==1 | classOut==2 | classOut==3 | classOut==7))=1;
    
    % Replace with closest pixel
    [oldR oldC]=find(~isnan(classOut) & replaceMat==0);
    [addR addC]=find(replaceMat==1);
    idx = knnsearch([oldR oldC], [addR addC]);
    nearest_OldValue = classOut(sub2ind(size(classOut), oldR(idx), oldC(idx)));
    classOut(sub2ind(size(classOut), addR, addC))=nearest_OldValue;
end
%% Remove nans
classOut(isnan(data.DBZ))=nan;
end