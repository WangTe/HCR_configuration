function x = cid_cmap2(n);


if nargin==1 & isempty(n)
  n = size(get(gcf,'Colormap'),1);
end;

cmap = [...
   [0 100   0]./255; ...
   [85 107  47]./255; ...
   [34 139  34]./255; ...
   [0 205 102]./255; ...
   [60 179 113]./255; ...
   [102 205 170]./255; ...
   [123 104 238]./255; ...
   [0   0 255]./255; ...
   [0   0 139]./255; ...
   [104  34 139]./255; ...
   [139  58  98]./255; ...
   [176  48  96]./255; ...
   [139  34  82]./255; ...
   [160  82  45]./255; ...
   [210 105  30]./255; ...
   [218 165  32]./255; ...
   [255 255   0]./255; ...
   [233 150 122]./255; ...
   [250 128 114]./255; ...
   [238  44  44]./255; ...
   [255  20 147]./255; ...
   [211 211 211]./255; ...
   [255 250 250]./255; ...
   [0   0   0]./255; ...
   ];

if nargin < 1
  n = size(cmap,1);
end;

x = interp1(linspace(0,1,size(cmap,1)),cmap(:,1),linspace(0,1,n)','linear');
x(:,2) = interp1(linspace(0,1,size(cmap,1)),cmap(:,2),linspace(0,1,n)','linear');
x(:,3) = interp1(linspace(0,1,size(cmap,1)),cmap(:,3),linspace(0,1,n)','linear');

x = min(x,1);
x = max(x,0);