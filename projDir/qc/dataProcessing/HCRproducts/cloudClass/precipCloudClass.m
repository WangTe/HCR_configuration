function cloudFlag=precipCloudClass(cloudParams)
% Classify precipitating clouds into Deep (1), Ns (2), Cu (3), Sc (4), St (5), Ac (7)
cloudFlag=nan;

%% Deep flag
deepFlag=0;

if abs(cloudParams.meanLat)<23.5
    if (cloudParams.maxAgl>12 & cloudParams.max10dbzAgl>8.2) | ...
            (cloudParams.maxAgl>14 & cloudParams.meanThickness>12) | ...
            (cloudParams.meanMaxAgl>8.5 & cloudParams.max10dbzAgl>8.4)
        deepFlag=1;
    end
elseif (cloudParams.maxAgl>10 & cloudParams.max10dbzAgl>7.2) | ...
        cloudParams.max10dbzAgl>7.8 | ...
        ((cloudParams.maxAgl-cloudParams.max10dbzAgl)<1 & cloudParams.max10dbzAgl>7.5)
    deepFlag=1;
end

%% Conv flag

convFlag=0;

if deepFlag==1
    convFlag=1;
elseif (cloudParams.intPrecip>5 | cloudParams.maxMaxRefl>14 | cloudParams.meanMaxRefl>4) & ...
        (cloudParams.lengthKM<80 | cloudParams.stdMaxAgl>0.5 | cloudParams.meanMaxRefl>4) & ...
        (cloudParams.meanMaxAgl-cloudParams.max10dbzAgl)<0.34 & ...
        cloudParams.max10dbzAgl>3 & cloudParams.meanThickness<5
    convFlag=1;
end

%% Precip cloud decision tree

if cloudParams.meanBaseTemp>-6
    if cloudParams.meanThickness<2.6 & cloudParams.meanMinAgl<2 & cloudParams.maxAgl<4.5
        if cloudParams.meanThickness<2.5 & cloudParams.intPrecip==0 % I am adding the intense Precip criterium to distinguish from small cumuli
            cloudFlag=5;
        elseif cloudParams.meanMaxAgl<3.5 & cloudParams.max10dbzAgl<3 & ...
                (cloudParams.intPrecip==0 | cloudParams.lengthKM>100) & ...
                veryIntPrecip==0
            cloudFlag=4;
        else
            cloudFlag=3;
        end
    elseif ((cloudParams.meanThickness<=6 & cloudParams.lengthKM<75) | ...
            (cloudParams.meanThickness<=3 & cloudParams.lengthKM<50)) & ...
            (cloudParams.meanMaxRefl+cloudParams.stdMaxRefl)>=6 & ...
            cloudParams.maxAgl<=7 & cloudParams.stdMaxAgl>=0.3
        cloudFlag=3;
    elseif ((cloudParams.numPrecip*1.4)>50 | (cloudParams.maxThickness<8 & cloudParams.lengthKM>60) | ...
            (cloudParams.maxThickness>7 & cloudParams.max10dbzAgl<3.5 & cloudParams.lengthKM>30) | ...
            (cloudParams.meanThickness<10.2 & cloudParams.lengthKM>45 & ...
            cloudParams.meanMaxRefl<10 & cloudParams.max10dbzAgl<4.2) & ...
            (cloudParams.meanThickness<8.2 & cloudParams.lengthKM>25 & ...
            cloudParams.meanMaxRefl<10 & cloudParams.max10dbzAgl<2)) & ...
            (cloudParams.veryIntPrecip==0 | (cloudParams.max10dbzAgl<5 | cloudParams.veryIntPrecip>0)) & ...
            ((cloudParams.numPrecip/cloudParams.lengthKM*1.4)>0.3 | ...
            (cloudParams.meanThickness>5 & cloudParams.lengthKM>=270)) & ...
            ((convFlag==0 & cloudParams.lengthKM>25) | (cloudParams.lengthKM>100 & cloudParams.meanMinAgl<1.8)) & ... % Adding lengthKM>25 for smaller clouds
            deepFlag==0
        cloudFlag=2;
    elseif (((cloudParams.meanMaxAgl-cloudParams.meanMaxReflAgl)<2.1 & ...
            cloudParams.meanMaxRefl<5 & cloudParams.stdMaxAgl<0.3) | ...
            (cloudParams.meanMaxAgl>4 & cloudParams.maxMaxRefl<10 & ...
            cloudParams.meanMaxRefl<-1 & cloudParams.maxAgl<7) | ...
            (cloudParams.meanMaxAgl>4 & cloudParams.maxMaxRefl<7 & ...
            cloudParams.meanMaxRefl<0 & cloudParams.maxAgl<7) | ...
            (cloudParams.meanThickness<5 & cloudParams.meanMaxRefl<0.5 & cloudParams.stdMaxAgl<0.45) | ...
            (cloudParams.meanMaxAgl>3 & cloudParams.meanThickness>2.5 & ...
            cloudParams.meanThickness<4.5 & cloudParams.stdMaxAgl<0.3)) & ...
            convFlag==0
        cloudFlag=7;
    elseif cloudParams.meanThickness<5 | (cloudParams.meanThickness<6 & cloudParams.minTopTemp>-15)
        cloudFlag=3;
    else
        cloudFlag=1;
    end
elseif cloudParams.maxAgl<3.9 & cloudParams.meanThickness<2.5 & cloudParams.meanMinAgl<1.5 & ...
        (cloudParams.lengthKM>50 | cloudParams.maxMaxRefl<10)
    cloudFlag=4;
elseif cloudParams.meanThickness<2.5 & cloudParams.meanMinAgl>1.8
    cloudFlag=7;
elseif (cloudParams.lengthKM<50 & (cloudParams.meanMaxRefl+cloudParams.stdMaxRefl)>7) | ...
        (cloudParams.lengthKM<70 & (cloudParams.meanMaxRefl+cloudParams.stdMaxRefl)>12) | ...
        (convFlag==1 & cloudParams.meanThickness<3)
    cloudFlag=3;
else
    cloudFlag=2;
end
end

