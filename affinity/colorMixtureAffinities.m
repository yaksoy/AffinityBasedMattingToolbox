
% Color Mixture Non-local Pixel Affinities
% This function implements the color-mixture information flow in
% Yagiz Aksoy, Tunc Ozan Aydin, Marc Pollefeys, "Designing Effective 
% Inter-Pixel Information Flow for Natural Image Matting", CVPR, 2017
% when the input parameter 'useXYinLLEcomp' is false (default), and
% the affinity definition used in
% Xiaowu Chen, Dongqing Zou, Qinping Zhao, Ping Tan, "Manifold 
% preserving edit propagation", ACM TOG, 2012
% when 'useXYinLLEcomp' is true.
% All parameters other than image are optional. The output is a sparse
% matrix which has non-zero element for the non-local neighbors of
% the pixels given by binary map inMap.
% - K defines the number of neighbors from which LLE weights are 
%   computed.
% - outMap is a binary map that defines where the nearest neighbor 
%   search is done.
% - xyWeight determines how much importance is given to the spatial
%   coordinates in the nearest neighbor selection.

function Wcm = colorMixtureAffinities(image, K, inMap, outMap, xyWeight, useXYinLLEcomp)

    [h, w, ~] = size(image);
    N = h * w;

    if ~exist('K', 'var') || isempty(K)
        K = 20;
    end
    if ~exist('inMap', 'var') || isempty(inMap)
        inMap = true(h, w);
    end
    if ~exist('outMap', 'var') || isempty(outMap)
        outMap = true(h, w);
    end
    if ~exist('xyWeight', 'var') || isempty(xyWeight)
        xyWeight = 1;
    end
    if ~exist('useXYinLLEcomp', 'var') || isempty(useXYinLLEcomp)
        useXYinLLEcomp = false;
    end

    [inInd, neighInd, features] = findNonlocalNeighbors(image, K, xyWeight, inMap, outMap);

    if ~useXYinLLEcomp
        features = features(:, 1 : end - 2);
    end
    flows = zeros(size(inInd, 1), size(neighInd, 2));

    for i = 1 : size(inInd, 1)
        flows(i, :) = localLinearEmbedding(features(inInd(i), :)', features(neighInd(i, :), :)', 1e-10);
    end
    flows = flows ./ repmat(sum(flows, 2), [1, K]);
    
    inInd = repmat(inInd, [1, K]);
    Wcm = sparse(inInd(:), neighInd(:), flows, N, N);
end