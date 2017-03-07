
% Matting Affinity
% This function implements the image matting approach described in
% Anat Levin, Dani Lischinski, Yair Weiss, "A Closed Form Solution to 
% Natural Image Matting", IEEE TPAMI, 2008.
% All parameters other than image are optional. The output is a sparse
% matrix which has non-zero element for the non-local neighbors of
% the pixels given by binary map inMap.
% - windowRadius defines the size of the window where the local normal 
%   distributions are estimated.
% - epsilon defines the regularization coefficient used before inverting
%   covariance matrices. It should be larger for noisy images.

function W = mattingAffinity(image, inMap, windowRadius, epsilon)

    if ~exist('windowRadius', 'var') || isempty(windowRadius)
        windowRadius = 1;
    end
    if ~exist('epsilon', 'var') || isempty(epsilon)
        epsilon = 1e-7;
    end

    windowSize = 2 * windowRadius + 1;
    neighSize = windowSize^2;
    [h, w, c] = size(image);
    N = h * w;
    epsilon = epsilon / neighSize;
    
    % No need to compute affinities in known regions if a trimap is defined
    if nargin < 2 || isempty(inMap)
        inMap = true(size(image, 1), size(image, 2));
    end
    
    [meanImage, covarMat] = localRGBnormalDistributions(image, windowRadius, epsilon);

    % Determine pixels and their local neighbors
    indices = reshape((1 : h * w), [h w]);
    neighInd = im2col(indices, [windowSize windowSize], 'sliding')';
    inMap = inMap(windowRadius + 1 : end - windowRadius, windowRadius + 1 : end - windowRadius);
    neighInd = neighInd(inMap, :);
    inInd = neighInd(:, (neighSize + 1) / 2);
    pixCnt = size(inInd, 1);

    % Prepare in & out data
    image = reshape(image, [N, c]);
    meanImage = reshape(meanImage, [N, c]);
    flowRows = zeros(neighSize, neighSize, pixCnt);
    flowCols = zeros(neighSize, neighSize, pixCnt);
    flows = zeros(neighSize, neighSize, pixCnt);

    % Compute matting affinity
    for i = 1 : size(inInd, 1)
        neighs = neighInd(i, :);
        shiftedWinColors = image(neighs, :) - repmat(meanImage(inInd(i), :), [size(neighs, 2), 1]);
        flows(:, :, i) = shiftedWinColors * (covarMat(:, :, inInd(i)) \ shiftedWinColors');
        neighs = repmat(neighs, [size(neighs, 2), 1]);
        flowRows(:, :, i) = neighs;
        flowCols(:, :, i) = neighs';
    end
    flows = (flows + 1) / neighSize;
    W = sparse(flowRows(:), flowCols(:), flows(:), N, N);
    
    % Make sure it's symmetric
    W = W + W';

    % Normalize
    sumW = full(sum(W, 2));
    sumW(sumW < 0.05) = 1;
    W = spdiags(1 ./ sumW(:), 0, N, N) * W;
end