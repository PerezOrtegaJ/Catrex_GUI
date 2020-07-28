function [A,B,same] = Evaluate_Shape_Neurons(neuronsA,neuronsB,width,height)
% Evaluate neuron shape, neuronA by neuronB
%
%       [A,B,same] = Evaluate_Shape_Neurons(neuronsA,neuronsB,width,height)
%
% By Jesus Perez-Ortega, Nov 2019

n = length(neuronsA);
same = zeros(n,1);
for i = 1:n
    pixelsA = neuronsA(i).pixels;
    pixelsB = neuronsB(i).pixels;
    same(i) = Same_Shape(pixelsA,pixelsB,width,height);
end

same = logical(same);

A = neuronsA(same);
B = neuronsB(same);