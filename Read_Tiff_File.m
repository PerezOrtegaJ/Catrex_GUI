function [mov,prop] = Read_Tiff_File(file)
% Create a matrix from a tiff file
%
%       [mov,prop] = Read_Tiff_File(file)
%
% By Jesus Perez-Ortega Oct 2019

tic; disp('Loading TIF file info...')

% Get info from the file
info = imfinfo(file);
w = info(1).Width;
h = info(1).Height;
depth = info(1).BitDepth;

% Get offset and byte strip
strip_offset = info(1).StripOffsets;
strip_byte = info(1).StripByteCounts;

if length(strip_offset)>1
    error('Open and save the TIF file in ImageJ, then open it here again.')
end

if length(info) == 1
    frames = floor((info(1).FileSize-strip_offset)/strip_byte);
else
    frames = length(info);
end

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

% Estimated time from a MacBook Air core i5: 750 frames/s (256x256 8bit)
switch (depth)
    case 8
        estimated_time = round(frames/1500);
        mov = zeros(h,w,frames,'uint8');
    case 16
        estimated_time = round(frames/750);
        mov = zeros(h,w,frames,'uint16');
    case 32
        estimated_time = round(frames/750);
        mov = zeros(h,w,frames,'single');
end
tic; fprintf('Loading %i-bit frames... (estimated time: %i s)\n',depth,estimated_time)

% Read images
try
    file_id = fopen(file,'r');
    start_point = strip_offset+(0:(frames-1)).*strip_byte;
    for i = 1:frames
        % Go through each strip of data.
        fseek(file_id, start_point(i)+1, 'bof');

        % Read data of each frame depending of the depth
        switch(depth)
            case 8
                A = fread(file_id,[w h],'uint8=>uint8');
            case 16
                A = fread(file_id,[w h],'uint16=>uint16');
            case 32
                A = fread(file_id,[w h],'single=>single');
        end
        mov(:,:,i) = A';
    end
    fclose(file_id);
catch me
    disp(me.identifier)
    fclose(file_id);
end

if depth == 32
    mov = uint16(mov);
    depth = 16;
end

prop.height = h;
prop.width = w;
prop.depth = depth;
prop.frames = frames;
t=toc; disp(['   Done (' num2str(t) ' seconds)'])