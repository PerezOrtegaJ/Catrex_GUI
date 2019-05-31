function Save_Video(data,name,options)
% Save data in an AVI file
%
%       Save_Video(data,name)
%
% Jesus Perez-Ortega May-19

if nargin==2
    options.Profile = 'Grayscale AVI';
    options.FrameRate = 30;
end

frames = size(data,3);

% Set and open the file
v = VideoWriter(name,options.Profile);
v.FrameRate = options.FrameRate;
open(v);

if strcmp(options.Profile, 'Grayscale AVI')
    % Save frames
    for i = 1:frames 
       writeVideo(v,data(:,:,i));
    end
else
    % identify class
    switch(class(data))
        case 'uint8'
            map = gray(2^8);
        case 'uint16'
            map = gray(2^16);
    end
    
    % Save frames
    for i = 1:frames 
       frame = im2frame(data(:,:,i),map);
       writeVideo(v,frame);
    end
end
close(v);
