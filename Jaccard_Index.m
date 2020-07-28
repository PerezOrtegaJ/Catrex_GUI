function [jaccard,jA,jB] = Jaccard_Index(setA,setB)
% Compute the jaccard index between two sets
%
%       jaccard = Jaccard_Index(setA,setB)
%
% By Jesus Perez-Ortega Sep 2019

% Intersection
in = numel(intersect(setA,setB));

% Union
un = numel(union(setA,setB));

% Jaccard index
jaccard = in/un;

% Relative to A
unA = numel(unique(setA));
jA = in/unA;

% Relative to B
unB = numel(unique(setB));
jB = in/unB;