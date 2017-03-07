
% Known-to-Unknown Information Flow
% This function implements the known-to-unknown information flow in
% Yagiz Aksoy, Tunc Ozan Aydin, Marc Pollefeys, "Designing Effective 
% Inter-Pixel Information Flow for Natural Image Matting", CVPR, 2017.
% All parameters other than image and the trimap are optional. The outputs
% are the weight of FG pixels inside the unknown region, and the confidence
% on these estimated values.
% - K defines the number of neighbors found in FG and BG from which
%   LLE weights are computed.
% - xyWeight determines how much importance is given to the spatial
%   coordinates in the nearest neighbor selection.

function [alphaEst, conf] = knownToUnknownColorMixture(image, trimap, K, xyWeight)

    if ~exist('K', 'var') || isempty(K)
        K = 7;
    end
    if ~exist('xyWeight', 'var') || isempty(xyWeight)
        xyWeight = 10;
    end

    image= im2double(image);
    trimap = im2double(trimap(:,:,1));
    bg = trimap < 0.2;
    fg = trimap > 0.8;
    unk = ~(bg | fg);

    % Find neighbors of unknown pixels in FG and BG
    [inInd, bgInd, features] = findNonlocalNeighbors(image, K, xyWeight, unk, bg);
    [~, fgInd] = findNonlocalNeighbors(image, K, xyWeight, unk, fg);
    neighInd = [fgInd, bgInd];

    % Compute LLE weights and estimate FG and BG colors that got into the mixture
    features = features(:, 1 : end - 2);
    flows = zeros(size(inInd, 1), size(neighInd, 2));
    fgCols = zeros(size(inInd, 1), 3);
    bgCols = zeros(size(inInd, 1), 3);
    for i = 1 : size(inInd, 1)
        flows(i, :) = localLinearEmbedding(features(inInd(i), :)', features(neighInd(i, :), :)', 1e-10);
        fgCols(i, :) = sum(features(neighInd(i, 1 : K), :) .* repmat(flows(i, 1 : K)', [1 3]), 1);
        bgCols(i, :) = sum(features(neighInd(i, K + 1 : end), :) .* repmat(flows(i, K + 1 : end)', [1 3]), 1);
    end

    % Estimated alpha is the sum of weights of FG neighbors
    alphaEst = trimap;
    alphaEst(unk) = sum(flows(:, 1 : K), 2);

    % Compute the confidence based on FG - BG color difference
    unConf = fgCols - bgCols;
    unConf = sum(unConf .* unConf, 2) / 3;
    conf = double(fg | bg);
    conf(unk) = unConf;
end