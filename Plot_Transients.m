function Plot_Transients(transients,name,mode,fps,new_figure)
% Plot Ca transients
%
%       Plot_Transients(transients,name,mode,fps)
%
%       default: name = ''; mode = 'raster'; fps = 1; new_figure = true
%
% Jesus Perez-Ortega March-19

switch(nargin)
    case 1
        name = [];
        mode = 'raster';
        fps = 1;
        new_figure = true;
    case 2
        mode = 'raster';
        fps = 1;
        new_figure = true;
    case 3
        fps = 1;
        new_figure = true;
    case 4
        new_figure = true;
end

% Get information
[n_cells,n_frames] = size(transients);

% Set Figure
if new_figure
    Set_Figure(['Transients - ' name],[0 0 1400 400]);
    Set_Axes('axTransients',[0 0 1 1]); hold on
end

title(strrep([name ' - N = ' num2str(n_cells)],'_','-'))
switch (mode)
    case 'raster'
        imagesc(transients); colormap(flipud(gray))
        ylabel('cell number')
        c=colorbar;
        c.Label.String = 'Intensity (\DeltaF)';
    case 'basic'
        % Read color
        colors = Read_Colors(n_cells);
        
        % Plot
        for i = 1:n_cells
            plot(transients(i,:),'color',colors(i,:)); hold on
        end
        ylabel('Intensity (\DeltaF)')
    case 'steps'
        % Set the size of steps
        step_x = n_frames/n_cells/2;
        step_y = max(transients(:))*0.05;

        % Read color
        colors = Read_Colors(n_cells);
        
        % Plot
        c = mod(n_cells,5)+1;
        for i = n_cells:-1:1
            if (c==1)
                c=5;
            else
                c=c-1;
            end
            time = ((step_x*i):(step_x*i+n_frames-1))/2.55;
            plot(time,transients(i,:)+step_y*i,'color',colors(i,:)); hold on
        end    
        ylabel('Intensity (\DeltaF)')
    case 'separated'
        % Set the size of steps
        increment = 0;
        
        % Read color
        colors = Read_Colors(n_cells);
        
        % Plot
        for i = 1:n_cells
            signal = transients(i,:)-min(transients(i,:));
            plot(signal+increment,'color',colors(i,:)); hold on
            plot([0 n_frames],repmat(min(signal+increment),1,2),'--','color',[0.5 0.5 0.5])
            increment = increment + max(signal);
        end    
        ylabel('Intensity (\DeltaF)')
    otherwise
        warning('The ''raster'' mode was applied.')
        imagesc(transients,[0,1]); colormap(flipud(gray))
        ylabel('cell number')
        c=colorbar;
        c.Label.String = 'Intensity (\DeltaF)';
end
xlim([1 n_frames])

Set_Label_Time(n_frames,fps)