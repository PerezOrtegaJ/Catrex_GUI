function mov = Phase_Offset_Correction(mov,shift)
% Correct the phase offset from images acquired by two photon in resonant
% mode
%
%       mov = Phase_Offset_Correction(mov,shift)
%
% By Jesus Perez-Ortega, Dec 2019

[nRows,~,nFrames] = size(mov);

if shift<0
    indices = 2:2:nRows;
else
    indices = 1:2:nRows;
end

for i = 1:nFrames
    % Get single image
    im = mov(:,:,i);

    % Correct images
    for j = indices
        im(j,1+shift:end) = im(j,1:end-shift);
    end
    
    % Replace
    mov(:,:,i) = im;
end