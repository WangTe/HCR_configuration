function[classOut]=calc_pid_hsrl_clean_eff(Beta,Delta,temp)

%   Membership functions for particle detection
% 1:Beta  2:Delta

w=[40 30 30];

% pid_hsrl
%  1   no signal
%  2   cloud liquid
%  3   Drizzle
%  4   Aerosol1
%  5   SLW
%  6   Ice crystals
%  7   Aerosol2

result=nan(7,size(Beta,1),size(Beta,2));

%  Membership functions for no signal
m=nan(3,size(Beta,1),size(Beta,2));
m(1,:,:)= zmf(Beta,[0.4e-10,0.2e-9]); % no signal
m(2,:,:)=smf(Delta,[0, 0.01]);
m(3,:,:)=smf(temp,[203,205.]);

result(1,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3);

%  Membership functions for cloud liquid
m=nan(3,size(Beta,1),size(Beta,2));
m(1,:,:)=trapmf(Beta,[1.e-4,1.2e-4,1.7e-3,1.9e-3]);
m(2,:,:)=trapmf(Delta,[-0.1, 0.01,0.03,0.05]);
m(3,:,:)=trapmf(temp,[271.,273.,300.,305.]);

result(2,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3);

%  Membership functions for drizzle
m=nan(3,size(Beta,1),size(Beta,2));
m(1,:,:)=trapmf(Beta,[0.5e-5,0.7e-5,0.8e-4,1.0e-4]);
m(2,:,:)=trapmf(Delta,[0.01,0.02,0.3,0.4]);
m(3,:,:)=trapmf(temp,[230.,233.,300.,305.]);

result(3,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3);

%  Membership functions for aerosol 1
m=nan(3,size(Beta,1),size(Beta,2));
m(1,:,:)=trapmf(Beta,[0.2e-9,0.4e-9,0.8e-7,1.2e-7]);
m(2,:,:)=smf(Delta,[0, 0.01]);
m(3,:,:)=smf(temp,[203,205.]);

result(4,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3);

%  Membership functions for SLW
m=nan(3,size(Beta,1),size(Beta,2));
m(1,:,:)=trapmf(Beta,[1.e-4,1.2e-4,1.7e-3,1.9e-3]);
m(2,:,:)=trapmf(Delta,[-0.1, 0.01,0.03,0.05]);
m(3,:,:)=zmf(temp,[273,271]);

result(5,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3);

%  Membership functions for ice
m=nan(3,size(Beta,1),size(Beta,2));
m(1,:,:)=trapmf(Beta,[0.8e-6,1.2e-6,0.8e-4,1.0e-4]);
m(2,:,:)= trapmf(Delta,[0.13,0.15,0.50, 0.6]);
m(3,:,:)=zmf(temp,[273,271]);

result(6,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3);

%  Membership functions for aerosol 2
m=nan(3,size(Beta,1),size(Beta,2));
m(1,:,:)=trapmf(Beta,[0.2e-9,0.4e-9,1.8e-6,2e-6]);% Aerosol 2
m(2,:,:)= trapmf(Delta,[-0.1,0.01,0.25,0.30]);
m(3,:,:)=smf(temp,[203,205.]);

result(7,:,:)=m(1,:,:)*w(1)+m(2,:,:)*w(2)+m(3,:,:)*w(3);

clear m

max1=squeeze(nanmax(result,[],1));
maxMat=repmat(max1,[1,1,7]);
maxMat=permute(maxMat,[3,1,2]);
resMinusMax=result-maxMat;
zerosMat=zeros(size(result));
zerosMat(resMinusMax==0)=1;

classOut=nan(size(Beta));

for ii=1:7
    testMat=squeeze(zerosMat(ii,:,:));
    classOut(isnan(classOut) & testMat==1)=ii;
end

end