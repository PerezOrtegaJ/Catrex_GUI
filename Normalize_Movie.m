function [normalized,max_norm,mean_movie,std_movie] = Normalize_Movie(movie)
% Normalize the pixel along the movie
%
% Jesus Perez-Ortega April-19

% Get average
mean_movie = mean(movie,3);

if isa(movie,'uint8')
    % Get standar deviation
    normalized = bsxfun(@minus, movie, uint8(mean_movie));
    std_movie = sqrt(mean(normalized.*normalized, 3));

    % Normalized
    normalized = bsxfun(@times, single(normalized), 1./std_movie);
    normalized = uint8(normalized/max(normalized(:))*255);
elseif isa(movie,'uint16')
    % Get standar deviation
    normalized = bsxfun(@minus, movie, uint16(mean_movie));
    std_movie = sqrt(mean(normalized.*normalized, 3));

    % Normalized
    normalized = bsxfun(@times, single(normalized), 1./std_movie);
    normalized = uint16(normalized);
else
    % Get standar deviation
    normalized = bsxfun(@minus, movie, mean_movie);
    std_movie = sqrt(mean(normalized.*normalized, 3));

    % Normalize
    normalized = bsxfun(@times, normalized, 1./std_movie);
end
max_norm = max(normalized,[],3);