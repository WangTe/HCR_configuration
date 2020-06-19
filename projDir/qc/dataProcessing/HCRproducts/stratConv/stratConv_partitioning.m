% Calculate liquid water content from HCR ocean return

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input variables %%%%%%%%%%%%%%%%%%%%%%%%%%

project='otrec'; %socrates, aristo, cset, otrec
quality='qc2'; %field, qc1, or qc2
dataFreq='10hz';

ylimUpper=15;
adjustZeroMeter=350; % Assume melting layer is adjustZeroMeter below zero degree altitude

meltArea=2000; % melting layer +/- meltArea (meters) is considered in strat conv velocity algorithm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('~/git/HCR_configuration/projDir/qc/dataProcessing/'));

figdir=['/h/eol/romatsch/hcrCalib/clouds/stratConv/'];

dataDir=HCRdir(project,quality,dataFreq);

startTime=datetime(2019,8,7,16,35,0);
endTime=datetime(2019,8,7,16,45,0);

%% Get data

fileList=makeFileList(dataDir,startTime,endTime,'xxxxxx20YYMMDDxhhmmss',1);

data=[];

data.DBZ = [];
data.TEMP=[];
data.PRESS=[];
data.RH=[];
data.TOPO=[];
data.FLAG=[];
data.LDR=[];
data.WIDTH=[];
data.VEL_CORR=[];
data.pitch=[];

dataVars=fieldnames(data);

% Load data
data=read_HCR(fileList,data,startTime,endTime);

frq=ncread(fileList{1},'frequency');

% Check if all variables were found
for ii=1:length(dataVars)
    if ~isfield(data,dataVars{ii})
        dataVars{ii}=[];
    end
end

dataVars=dataVars(~cellfun('isempty',dataVars));

%% Find melting layer and separate warm and cold precip

data.dbzMasked=data.DBZ;
data.dbzMasked(data.FLAG>1)=nan;

findMelt=f_meltLayer(data,adjustZeroMeter);
oneInds=find(findMelt==1);
twoInds=find(findMelt==2);
threeInds=find(findMelt==3);

meltType=sum(findMelt,1,'omitnan');

meltInd=nan(size(data.time));
warmRefl=nan(size(data.DBZ));
coldRefl=nan(size(data.DBZ));

for ii=1:length(meltInd)
    meltRay=findMelt(:,ii);
    meltInd(ii)=min(find(~isnan(meltRay)));
    
    warmRefl(meltInd(ii):end,ii)=data.dbzMasked(meltInd(ii):end,ii);
    coldRefl(1:meltInd(ii)-1,ii)=data.dbzMasked(1:meltInd(ii)-1,ii);
end

%% Cloud puzzle

cloudPuzzle=f_cloudPuzzle_radial(data);

%% Stratiform convective partitioning
stratConv=f_stratConv(data,cloudPuzzle,findMelt,meltArea);

%% Plot strat conv
close all

timeMat=repmat(data.time,size(data.TEMP,1),1);

f1 = figure('Position',[200 500 1500 900],'DefaultAxesFontSize',12);

s1=subplot(3,1,1);
hold on
l1=plot(data.time,stratConv,'-b','linewidth',2);
ylabel('Strat (0), conv (1)');
ylim([-1 2]);
grid on
set(gca,'YColor','k');

xlim([data.time(1),data.time(end)]);

title([datestr(data.time(1)),' to ',datestr(data.time(end))])
s1pos=s1.Position;

s2=subplot(3,1,2);

colormap jet

hold on
surf(data.time,data.asl./1000,data.dbzMasked,'edgecolor','none');
view(2);
scatter(timeMat(oneInds),data.asl(oneInds)./1000,10,'c','filled');
scatter(timeMat(twoInds),data.asl(twoInds)./1000,10,'b','filled');
scatter(timeMat(threeInds),data.asl(threeInds)./1000,10,'g','filled');
ax = gca;
ax.SortMethod = 'childorder';
ylabel('Altitude (km)');
caxis([-25 25]);
ylim([0 ylimUpper]);
xlim([data.time(1),data.time(end)]);
colorbar
grid on
title('Reflectivity (dBZ)')
s2pos=s2.Position;
s2.Position=[s2pos(1),s2pos(2),s1pos(3),s2pos(4)];

s3=subplot(3,1,3);

colmap=[0 0 1;1 0 0;1 0 1];

hold on
surf(data.time,data.asl./1000,stratConv,'edgecolor','none');
view(2);
colormap(s3,colmap)
ylabel('Altitude (km)');
caxis([0 2]);
ylim([0 ylimUpper]);
xlim([data.time(1),data.time(end)]);
colorbar
grid on
title('Stratiform/convective')
s3pos=s3.Position;
s3.Position=[s3pos(1),s3pos(2),s1pos(3),s3pos(4)];

set(gcf,'PaperPositionMode','auto')
print(f1,[figdir,project,'_stratConv_',datestr(data.time(1),'yyyymmdd_HHMMSS'),'_to_',datestr(data.time(end),'yyyymmdd_HHMMSS')],'-dpng','-r0')
