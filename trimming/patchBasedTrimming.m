
% Patch-Based Trimming
% This function implements the trimap trimming approach described in
% Yagiz Aksoy, Tunc Ozan Aydin, Marc Pollefeys, "Designing Effective 
% Inter-Pixel Information Flow for Natural Image Matting", CVPR, 2017.
% The input parameters other than image and trimap are optional.
% - minDist and maxDist define a good match, and a match in BG that
%   rejects a good match in FG, and vice versa.
% - windowRadius defines the size of the window where the local normal 
%   distributions are estimated
% - K defines the number of nearest neighbors found using the mean
%   vectors before the Bhattacharyya distance comparison.

function trimap = patchBasedTrimming(image, trimap, minDist, maxDist, windowRadius, K)

    if ~exist('minDist', 'var') || isempty(minDist)
        minDist = 0.25;
    end
    if ~exist('maxDist', 'var') || isempty(maxDist)
        maxDist = 0.90;
    end
    if ~exist('windowRadius', 'var') || isempty(windowRadius)
        windowRadius = 1;
    end
    if ~exist('K', 'var') || isempty(K)
        K = 10;
    end

    image = im2double(image);
    trimap = im2double(trimap(:,:,1));
    [h, w, ~] = size(image);

    epsilon = 1e-8;

    fg = trimap > 0.8;
    bg = trimap < 0.2;
    unk = ~(fg | bg);

    [meanImage, covarMat] = localRGBnormalDistributions(image, windowRadius, epsilon);

    [unkInd, fgNeigh] = findNonlocalNeighbors(meanImage, K, -1, unk, fg);
    [~, bgNeigh] = findNonlocalNeighbors(meanImage, K, -1, unk, bg);

    meanImage = reshape(meanImage, [h * w, size(meanImage, 3)]);

    fgBhatt = zeros(K, 1);
    bgBhatt = zeros(K, 1);
    for i = 1 : size(unkInd, 1)
        pixMean = meanImage(unkInd(i), :)';
        pixCovar = covarMat(:, :, unkInd(i));
        pixDet = det(pixCovar);
        for n = 1 : K
            nMean = meanImage(fgNeigh(i, n), :)' - pixMean;
            nCovar = covarMat(:, :, fgNeigh(i, n));
            nDet = det(nCovar);
            nCovar = (pixCovar + nCovar) / 2;
            fgBhatt(n) = 0.125 * nMean' * (nCovar \ nMean) + 0.5 * log(det(nCovar) / sqrt(pixDet * nDet)); % Bhattacharyya distance
        end
        for n = 1 : K
            nMean = meanImage(bgNeigh(i, n), :)' - pixMean;
            nCovar = covarMat(:, :, bgNeigh(i, n));
            nDet = det(nCovar);
            nCovar = (pixCovar + nCovar) / 2;
            bgBhatt(n) = 0.125 * nMean' * (nCovar \ nMean) + 0.5 * log(det(nCovar) / sqrt(pixDet * nDet)); % Bhattacharyya distance
        end
        minFGdist = min(fgBhatt);
        minBGdist = min(bgBhatt);
        if minFGdist < minDist
            if minBGdist > maxDist
                trimap(unkInd(i)) = 1;
            end
        elseif minBGdist < minDist
            if minFGdist > maxDist
                trimap(unkInd(i)) = 0;
            end
        end
    end
end