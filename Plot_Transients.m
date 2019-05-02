function Plot_Transients(transients,name,mode,fps)
% Plot Ca transients
%
% Jesus Perez-Ortega March-19

switch(nargin)
    case 1
        name = [];
        mode = 'raster';
        fps = 1;
    case 2
        mode = 'raster';
        fps = 1;
    case 3
        fps = 1;
end

% Get information
[n_cells,n_frames] = size(transients);

% Set Figure
Set_Figure(['Transients - ' name],[0 0 1400 400]);
Set_Axes('axTransients',[0 0 1 1]); hold on
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
            plot(transients(i,:),'color',colors(i,:))
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
            plot(time,transients(i,:)+step_y*i,'color',colors(i,:))
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
            plot(signal+increment,'color',colors(i,:))
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

if(n_frames/fps<30)
    set(gca,'box','off','xtick',0:fps:n_frames,...
        'xticklabel',0:n_frames/fps)
    xlabel('Time (s)'); 
elseif(n_frames/fps/60<3)
    set(gca,'box','off','xtick',0:10*fps:n_frames,...
        'xticklabel',0:n_frames/fps/10)
    xlabel('Time (s)'); 
elseif(n_frames/fps/60<60)
    set(gca,'box','off','xtick',0:60*fps:n_frames,...
        'xticklabel',0:n_frames/fps/60)
    xlabel('Time (min)'); 
else
    set(gca,'box','off','xtick',0:60*60*fps:n_frames,...
        'xticklabel',0:n_frames/fps/60/60)
    xlabel('Time (h)'); 
end