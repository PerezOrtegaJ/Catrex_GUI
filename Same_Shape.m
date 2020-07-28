function same = Same_Shape(pixelsA,pixelsB,width,height)
% Compare the shape between two neurons and decide wheter is the same shape
% or not
%
%       same = Same_Shape(neuronA,neuronB)
%
% By Jesus Perez-Ortega, Nov 2019

% Draw the mask
maskA = zeros(height,width);
maskB = zeros(height,width);
maskA(pixelsA) = 1;
maskB(pixelsB) = 1;

% Get shape properties
propA = regionprops(maskA,'Circularity','Eccentricity','Orientation','Perimeter');
propB = regionprops(maskB,'Circularity','Eccentricity','Orientation','Perimeter');

% Compare 
circ = abs(propA.Circularity-propB.Circularity) < 0.2;
ecc = abs(propA.Eccentricity-propB.Eccentricity) < 0.2;
ori = abs(propA.Orientation-propB.Orientation) < 15;
per = abs(propA.Perimeter-propB.Perimeter) < 5;
jac = numel(intersect(pixelsA,pixelsB))/numel(union(pixelsA,pixelsB));

% Veredict (at least 3 properties in the limits) and 0.3 (~50% shared pixels)
if sum([circ ecc ori per])>1 || jac>0.3
    same = true;
else
    same = false;
end