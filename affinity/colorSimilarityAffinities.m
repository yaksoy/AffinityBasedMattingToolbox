
% Color Similarity Non-local Pixel Affinities
% This function implements the affinity based on color differences 
% first used for image matting in the paper
% Qifeng Chen, Dingzeyu Li, Chi-Keung Tang, "KNN Matting", IEEE 
% TPAMI, 2013.
% All parameters other than image are optional. The output is a sparse
% matrix which has non-zero element for the non-local neighbors of
% the pixels given by binary map inMap.
% - K defines the number of neighbors from which LLE weights are 
%   computed.
% - outMap is a binary map that defines where the nearest neighbor 
%   search is done.
% - xyWeight determines how much importance is given to the spatial
%   coordinates in the nearest neighbor selection.
% - When useHSV is false (default), the search is done i [r g b x y] space,
%   otherwise the feature space is [cos(h) sin(h), s, v, x, y].

function Wcs = colorSimilarityAffinities(image, K, inMap, outMap, xyWeight, useHSV)

    [h, w, ~] = size(image);
    N = h * w;

    if ~exist('K', 'var') || isempty(K)
        K = 5;
    end
    if ~exist('inMap', 'var') || isempty(inMap)
        inMap = true(h, w);
    end
    if ~exist('outMap', 'var') || isempty(outMap)
        outMap = true(h, w);
    end
    if ~exist('xyWeight', 'var') || isempty(xyWeight)
        xyWeight = 0.05;
    end
    if ~exist('useHSV', 'var') || isempty(useHSV)
        useHSV = false;
    end

    if useHSV
        image = rgb2hsv(image);
        image = cat(3, cos(image(:, :, 1)) * 2 * pi, sin(image(:, :, 1)) * 2 * pi, image(:,:,2:3));
    end

    [~, neighInd, ~] = findNonlocalNeighbors(image, K, xyWeight, inMap, outMap);

    % This behaviour below, decreasing the xy-weight and finding a new set of neighbors, is taken 
    % from the public implementation of KNN matting by Chen et al.
    [inInd, neighInd2, features] = findNonlocalNeighbors(image, ceil(K / 5), xyWeight / 100, inMap, outMap);
    neighInd = [neighInd, neighInd2];
    features(:, end-1 : end) = features(:, end-1 : end) / 100;

    inInd = repmat(inInd, [1, size(neighInd, 2)]);
    flows = max(1 - sum(abs(features(inInd(:), :) - features(neighInd(:), :)), 2) / size(features, 2), 0);

    Wcs = sparse(inInd(:), neighInd(:), flows, N, N);
    Wcs = (Wcs + Wcs') / 2; % If p is a neighbor of q, make q a neighbor of p
end