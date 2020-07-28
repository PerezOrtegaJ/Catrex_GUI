function PNR = Get_Peak_To_Noise(movie,cellDiameter)
% compute correlation image of endoscopic data. it has to spatially filter the data first
%
%       PNR = Get_Peak_To_Noise(movie,cellDiameter)
%
% Input:
%   movie:  imaging data
%   cellDiameter:   maximum size of a neuron
%
% Output:
%       PNR: peak to noise ratio
% Author: Pengcheng Zhou, Carnegie Mellon University. zhoupc1988@gmail.com
% Modified by Jesus Perez-Ortega, Sep 2019

%% use correlation to initialize NMF
% parameters
movie = double(movie);
[h,w,frames] = size(movie);
center_psf = true;
gSig = 0;   % width of the gaussian kernel approximating one neuron

%% preprocessing data
% create a spatial filter for removing background
if gSig>0
    % Center psf
    if center_psf
        psf = fspecial('gaussian', ceil(gSig*4+1), gSig);
        ind_nonzero = (psf(:)>=max(psf(:,1)));
        psf = psf-mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
    else
        psf = fspecial('gaussian', round(cellDiameter), gSig);
    end
else
    psf = [];
end

% divide data into multiple patches
if numel(movie) < 500^3
    patch_sz = [1, 1];
else
    x = sqrt(500^3/frames);
    patch_sz = ceil([h/x, w/x]);
end
r0_patch = round(linspace(1, h, 1+patch_sz(1)));
c0_patch = round(linspace(1, w, 1+patch_sz(2)));
nr_patch = length(r0_patch)-1;
nc_patch = length(c0_patch)-1;
PNR = zeros(h,w);

% compute correlation_image patch by patch
bd = round(cellDiameter);
n = nr_patch*nc_patch;
ten_perc = round(n/10);
i = 1;
for mr = 1:nr_patch
    r0 = max(1, r0_patch(mr)-bd); % minimum row index of the patch
    r1 = min(h, r0_patch(mr+1)+bd-1); % maximum row index of the patch
    for mc = 1:nc_patch
        c0 = max(1, c0_patch(mc)-bd); % minimum column index of the patch
        c1 = min(w, c0_patch(mc+1)+bd-1); % maximum column index of the patch
        
        % take the patch from the raw data
        nrows = (r1-r0+1);  % number of rows in the patch
        ncols = (c1-c0+1);  % number of columns in the patch
        Ypatch = double(movie(r0:r1, c0:c1, :));
        
        % spatially filter the data
        if isempty(psf)
            HY = Ypatch;
        else
            HY = imfilter(Ypatch, psf, 'replicate');
        end
        % copute signal to noise ratio
        HY = reshape(HY, [], frames);
        HY = bsxfun(@minus, HY, median(HY, 2));
        HY_max = max(HY, [], 2);
        Ysig = GetSn(HY);
        tmp_PNR = reshape(HY_max./Ysig, nrows, ncols);
        PNR(r0:r1, c0:c1) = max(PNR(r0:r1, c0:c1), tmp_PNR);
        
        %
        if ~mod(i,ten_perc)
            t = toc; 
            fprintf('   %d %%, %.1f s\n',round(i/n*100),t)
        end
        i = i+1;
    end
end