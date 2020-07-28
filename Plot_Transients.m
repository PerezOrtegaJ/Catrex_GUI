function Plot_Transients(transients,name,mode,fps,colors,newFigure,shift)
% Plot Ca transients
%
%       Plot_Transients(transients,name,mode,fps,colors,newFigure,shift)
%
%       default: name = ''; mode = 'raster'; fps = 1; newFigure = true;
%                shift = 0;
%
%       modes: 'raster', 'basic', 'step', 'separated'
%
% Jesus Perez-Ortega March-19
% Modified Oct 2019

switch(nargin)
    case 1
        name = [];
        mode = 'raster';
        fps = 1;
        colors = [];
        newFigure = true;
        shift = 0;
    case 2
        mode = 'raster';
        fps = 1;
        colors = [];
        newFigure = true;
        shift = 0;
    case 3
        fps = 1;
        colors = [];
        newFigure = true;
        shift = 0;
    case 4
        colors = [];
        newFigure = true;
        shift = 0;
    case 5
        newFigure = true;
        shift = 0;
    case 6
        shift = 0;
end

% Get information
[nCells,nFrames] = size(transients);

% Get colors
if isempty(colors)
    colors = Read_Colors(nCells);
elseif size(colors,1)==1
    colors = repmat(colors,nCells,1);
end
        

% Set Figure
if newFigure
    Set_Figure(['Transients - ' name],[0 0 1000 400]);
    Set_Axes('axTransients',[0 0 1 1]); hold on
end

title(strrep([name ' - N = ' num2str(nCells)],'_','-'))
switch (mode)
    case 'raster'
        imagesc(transients); colormap(flipud(gray))
        ylim([0.5 nCells+0.5])
        ylabel('cell number')
        c = colorbar;
        c.Label.String = 'Intensity (\DeltaF)';
    case 'basic'
        % Plot
        for i = 1:nCells
            plot(transients(i,:),'color',[0.6 0.6 0.6]); hold on
        end
        ylabel('Intensity (\DeltaF)')
    case 'steps'
        % Set the size of steps
        step_x = nFrames/nCells/2;
        step_y = max(transients(:))*0.05;
        
        % Plot
        c = mod(nCells,5)+1;
        for i = nCells:-1:1
            if (c==1)
                c=5;
            else
                c=c-1;
            end
            time = ((step_x*i):(step_x*i+nFrames-1))/2.55;
            plot(time,transients(i,:)+step_y*i,'color',colors(i,:)); hold on
        end    
        ylabel('Intensity (\DeltaF)')
    case 'separated'
        % Set the size of steps
        increment = 0;
        
        % Plot
        for i = 1:nCells
            signal = transients(i,:)-min(transients(i,:));
            plot(signal+increment,'color',colors(i,:)); hold on
            %plot([0 nFrames],repmat(min(signal+increment),1,2),'--','color',[0.5 0.5 0.5])
            increment = increment + max(signal);
        end    
        ylabel('Intensity (\DeltaF)')
    otherwise
        warning('The ''raster'' mode was applied.')
        imagesc(transients,[0,1]); colormap(flipud(gray))
        ylabel('cell number')
        c = colorbar;
        c.Label.String = 'Intensity (\DeltaF)';
end
xlim([1 nFrames])

Set_Label_Time(nFrames,fps,shift)