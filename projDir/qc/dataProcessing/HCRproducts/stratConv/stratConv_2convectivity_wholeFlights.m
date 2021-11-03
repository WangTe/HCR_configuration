% Calculate convectivity and convective/stratiform partitioning

clear all
close all

addpath(genpath('~/git/HCR_configuration/projDir/qc/dataProcessing/'));

project='otrec'; %socrates, aristo, cset
quality='qc3'; %field, qc1, or qc2
qcVersion='v3.0';
freqData='10hz'; % 10hz, 100hz, 2hz, or combined
whichModel='era5';

saveTime=0;

indir=HCRdir(project,quality,qcVersion,freqData);

[~,outdir]=modelDir(project,whichModel,quality,qcVersion,freqData);

% if strcmp(project,'otrec')
%     indir='/scr/sleet2/rsfdata/projects/otrec/hcr/qc2/cfradial/development/convStrat/10hz/';
% elseif strcmp(project,'socrates')
%     indir='/scr/snow2/rsfdata/projects/socrates/hcr/qc2/cfradial/development/convStrat/10hz/';
% end
% 
% outdir=[indir(1:end-36),'mat/convStrat/10hz/'];

infile=['~/git/HCR_configuration/projDir/qc/dataProcessing/scriptsFiles/flights_',project,'_data.txt'];

caseList = table2array(readtable(infile));

for aa=1:size(caseList,1)
    disp(['Flight ',num2str(aa)]);
    disp(['Starting at ',datestr(datetime('now'),'yyyy-mm-dd HH:MM')]);
    disp('Loading data ...');
    
    startTime=datetime(caseList(aa,1:6));
    endTime=datetime(caseList(aa,7:12));
    
    %% Get data
    
    fileList=makeFileList(indir,startTime,endTime,'xxxxxx20YYMMDDxhhmmss',1);
    
    data=[];
    
    data.DBZ_MASKED=[];
    data.VEL_MASKED=[];
    data.TOPO=[];
    data.TEMP=[];
    data.MELTING_LAYER=[];
    data.FLAG=[];
        
    dataVars=fieldnames(data);
    
    % Load data
    data=read_HCR(fileList,data,startTime,endTime);
    
    % Check if all variables were found
    for ii=1:length(dataVars)
        if ~isfield(data,dataVars{ii})
            dataVars{ii}=[];
        end
    end
    
    dataVars=dataVars(~cellfun('isempty',dataVars));
    
    ylimUpper=(max(data.asl(~isnan(data.DBZ_MASKED)))./1000)+0.5;

    % Take care of up pointing VEL
    data.VEL_MASKED(:,data.elevation>0)=-data.VEL_MASKED(:,data.elevation>0);

    %% Texture from reflectivity and velocity

    disp('Calculating reflectivity texture ...');

    pixRadDBZ=50; % Radius over which texture is calculated in pixels. Default is 50.
    dbzBase=-10; % Reflectivity base value which is subtracted from DBZ.

    dbzText=f_reflTexture(data.DBZ_MASKED,pixRadDBZ,dbzBase);

    disp('Calculating velocity texture ...');

    pixRadVEL=50;
    velBase=-20; % VEL base value which is subtracted from DBZ.

    velText=f_velTexture(data.VEL_MASKED,data.elevation,pixRadVEL,velBase);

    %% Convectivity

    % Convectivity
    upperLimDBZ=12;
    convDBZ=1/upperLimDBZ.*dbzText;

    upperLimVEL=5;
    convVEL=1/upperLimVEL.*velText;

    convectivity=convDBZ.*convVEL;
    convectivity(isnan(convectivity))=convDBZ(isnan(convectivity));

    %% Basic classification

    disp('Basic classification ...');

    stratMixed=0.4; % Convectivity boundary between strat and mixed.
    mixedConv=0.5; % Convectivity boundary between mixed and conv.

    classBasic=f_classBasicBoth(convectivity,stratMixed,mixedConv,data.MELTING_LAYER,data.elevation);

    %% Sub classification

    disp('Sub classification ...');

    classSub=f_classSubBoth(classBasic,data.asl,data.TOPO,data.MELTING_LAYER,data.TEMP,data.elevation,data.FLAG);
          
    %% Save
    disp('Saving stratConv field ...')

    convStrat=classSub;
    convStrat1D=max(convStrat,[],1);
    
    save([outdir,whichModel,'.convectivity.',datestr(data.time(1),'YYYYmmDD_HHMMSS'),'_to_',...
        datestr(data.time(end),'YYYYmmDD_HHMMSS'),'.Flight',num2str(aa),'.mat'],'convectivity');
    
    save([outdir,whichModel,'.convStrat.',datestr(data.time(1),'YYYYmmDD_HHMMSS'),'_to_',...
        datestr(data.time(end),'YYYYmmDD_HHMMSS'),'.Flight',num2str(aa),'.mat'],'convStrat');
    
    save([outdir,whichModel,'.convStrat1D.',datestr(data.time(1),'YYYYmmDD_HHMMSS'),'_to_',...
        datestr(data.time(end),'YYYYmmDD_HHMMSS'),'.Flight',num2str(aa),'.mat'],'convStrat1D');
    
    if saveTime
        timeHCR=data.time;
        save([outdir,whichModel,'.time.',datestr(data.time(1),'YYYYmmDD_HHMMSS'),'_to_',...
            datestr(data.time(end),'YYYYmmDD_HHMMSS'),'.Flight',num2str(aa),'.mat'],'timeHCR');
    end
end