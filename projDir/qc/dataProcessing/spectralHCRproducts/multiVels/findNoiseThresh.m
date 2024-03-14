function [noiseThresh,meanNoise,R2]=findNoiseThresh(powIn,avNum,vNoise)
% Find noise threshold and mean noise following
% Hildebrand and Sekhon, 1974 https://doi.org/10.1175/1520-0450(1974)013%3C0808:ODOTNL%3E2.0.CO;2

noiseThresh=10.^((vNoise+15)./10);
powLin=10.^(powIn./10);
powLin(isnan(powLin))=[];

R2=0;

while R2<1
    if R2<0.1
        stepDown=0.00001;
    elseif R2<0.5
        stepDown=0.000001;
    else
        stepDown=0.0000001;
    end

    powLin(powLin>noiseThresh)=[];
    % xCalc=1:length(powLin);
    sampleNum=length(powLin);
    % sig2r=(sum(xCalc.^2.*powLin,'omitmissing')./sum(powLin,'omitmissing')) ...
    %     -(sum(xCalc.*powLin,'omitmissing')./sum(powLin,'omitmissing')).^2;
    % sigN2=sampleNum.^2/12;
    meanNoise=sum(powLin)/sampleNum;
    Q=sum(powLin.^2/sampleNum)-meanNoise.^2;
    % R1=sigN2/sig2r;
    R2=meanNoise.^2/(Q*avNum);

    % plot(powLin)
    % hold on
    % plot([1,sampleNum],[noiseThresh,noiseThresh],'-c','LineWidth',1.5);
    % hold off

    noiseThresh=noiseThresh-stepDown;
end
noiseThresh=10*log10(noiseThresh+stepDown);
meanNoise=10*log10(meanNoise);
end