
% Find neighbors using the pixel colors and spatial ccordinates
% - K is the number of neighbors to be found
% - Parameters other than K and image are optional.
% - xyWeight sets the relative importance of spatial coordinates
% - inMap and outMap are binary maps determining the query and
%   search regions
% - Self matches are detected and removed if eraseSelfMatches is true
% - inInd and neighInd give pixel indices of query pixels and their neighbors.
% - features is noOfPixels X dimensions matrix used in neighbor search.

function [inInd, neighInd, features] = findNonlocalNeighbors(image, K, xyWeight, inMap, outMap, eraseSelfMatches)

    [h, w, c] = size(image);

    if ~exist('xyWeight', 'var') || isempty(xyWeight)
        xyWeight = 1;
    end
    if ~exist('inMap', 'var') || isempty(inMap)
        inMap = true(h, w);
    end
    if ~exist('outMap', 'var') || isempty(outMap)
        outMap = true(h, w);
    end
    if ~exist('eraseSelfMatches', 'var') || isempty(eraseSelfMatches)
        eraseSelfMatches = true;
    end

    features = reshape(image, [h*w, c]);
    if xyWeight > 0
        [x, y] = meshgrid(1 : w, 1 : h);
        x = xyWeight * double(x) / w;
        y = xyWeight * double(y) / h;
        features = [features x(:) y(:)];
    end

    inMap = inMap(:);
    outMap = outMap(:);
    indices = (1 : h * w)';
    inInd = indices(inMap);
    outInd = indices(outMap);

    if eraseSelfMatches
        % Find K + 1 matches to count for self-matches
        neighbors = knnsearch(features(outMap, :), features(inMap, :), 'K', K + 1);
        % Get rid of self-matches
        validNeighMap = true(size(neighbors));
        validNeighMap(inMap(inInd) & outMap(inInd), 1) = 0;
        validNeighMap(:, end) = ~validNeighMap(:, 1);
        validNeighbors = zeros(size(neighbors, 1), size(neighbors, 2) - 1);
        for i = 1 : size(validNeighbors, 1)
            validNeighbors(i, :) = neighbors(i, validNeighMap(i, :));
        end
        neighInd = outInd(validNeighbors);
    else
        neighbors = knnsearch(features(outMap, :), features(inMap, :), 'K', K);
        neighInd = outInd(neighbors);
    end
end