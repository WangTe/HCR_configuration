% add model data to cfradial files
clear all;
close all;

addpath(genpath('/h/eol/romatsch/gitPriv/utils/'));

project='otrec'; % socrates, cset, aristo, otrec
quality='qc1'; % field, qc1, qc2
freqData='10hz';
whichModel='era5';

formatOut = 'yyyymmdd';

infile=['/h/eol/romatsch/hcrCalib/oceanScans/biasInFiles/flights_',project,'_data.txt'];

caseList = table2array(readtable(infile));

indir=HCRdir(project,quality,freqData);
%indir='/scr/snow1/rsfdata/projects/otrec/hcr/qc0/cfradial/addvars/10hz/';

if strcmp(whichModel,'era5')
    modeldir=['/scr/sci/romatsch/data/reanalysis/ecmwf/era5interp/',project,'/',freqData,'/'];
elseif strcmp(whichModel,'ecmwf')
    modeldir=['/scr/sci/romatsch/data/reanalysis/ecmwf/forecastInterp/',project,'/',freqData,'/'];
end

%% Run processing

% Go through flights
for ii=1:size(caseList,1)
    
    disp(['Flight ',num2str(ii)]);
    startTime=datetime(caseList(ii,1:6));
    endTime=datetime(caseList(ii,7:12));
    
    fileList=makeFileList(indir,startTime,endTime,'xxxxxx20YYMMDDxhhmmss',1);
    
    if ~isempty(fileList)
        
        % Get model data
        model.antstat=[];
        model.flagfield=[];
        
        model=read_model(model,modeldir,startTime,endTime);
        timeModelNum=datenum(model.time);
        
        %% Loop through HCR data files
        for jj=1:length(fileList)
            infile=fileList{jj};
            
            disp(infile);
            
            % Find times that are equal
            startTimeIn=ncread(infile,'time_coverage_start')';
            startTimeFile=datetime(str2num(startTimeIn(1:4)),str2num(startTimeIn(6:7)),str2num(startTimeIn(9:10)),...
                str2num(startTimeIn(12:13)),str2num(startTimeIn(15:16)),str2num(startTimeIn(18:19)));
            timeRead=ncread(infile,'time')';
            timeHCR=startTimeFile+seconds(timeRead);
            
            timeHcrNum=datenum(timeHCR);
            
            [C,ia,ib] = intersect(timeHcrNum,timeModelNum);
            
            if length(timeHCR)~=length(ib)
                disp('Times do not match up.')
                return
            end
            
            % Write output
            fillVal=-99;
            
            modVars=fields(model);
            
            for kk=1:length(modVars)
                if ~strcmp((modVars{kk}),'time')
                    modOut.(modVars{kk})=model.(modVars{kk})(:,ib);
                    modOut.(modVars{kk})(isnan(modOut.(modVars{kk})))=fillVal;
                    modOut.(modVars{kk})=int16(modOut.(modVars{kk}));
                end
            end
            
            % Open file
            ncid = netcdf.open(infile,'WRITE');
            netcdf.setFill(ncid,'FILL');
            
            % Get dimensions
            dimtime = netcdf.inqDimID(ncid,'time');
            dimrange = netcdf.inqDimID(ncid,'range');
            
            % Define variables
            netcdf.reDef(ncid);
            varidFLAG = netcdf.defVar(ncid,'FLAG','NC_SHORT',[dimrange dimtime]);
            netcdf.defVarFill(ncid,varidFLAG,false,fillVal);
            varidANT = netcdf.defVar(ncid,'ANTFLAG','NC_SHORT',[dimtime]);
            netcdf.defVarFill(ncid,varidANT,false,fillVal);
            netcdf.endDef(ncid);
            
            % Write variables
            netcdf.putVar(ncid,varidFLAG,modOut.flagfield);
            netcdf.putVar(ncid,varidANT,modOut.antstat);
            
            netcdf.close(ncid);
            
            % Write attributes
            ncwriteatt(infile,'FLAG','long_name','data_flag');
            ncwriteatt(infile,'FLAG','standard_name','data_flag');
            ncwriteatt(infile,'FLAG','units','');
            ncwriteatt(infile,'FLAG','grid_mapping','grid_mapping');
            ncwriteatt(infile,'FLAG','coordinates','time range');
                        
            ncwriteatt(infile,'ANTFLAG','long_name','antenna_flag');
            ncwriteatt(infile,'ANTFLAG','standard_name','antenna_flag');
            ncwriteatt(infile,'ANTFLAG','units','');
            ncwriteatt(infile,'ANTFLAG','coordinates','time');
            
        end
    end
end