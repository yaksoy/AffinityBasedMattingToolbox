
% Trimming from Edges of the Unknown Region
% This function implements the trimap trimming approach described in
% Ehsan Shahrian, Deepu Rajan, Brian Price, Scott Cohen, "Improving 
% Image Matting using Comprehensive Sampling Sets", CVPR 2013
% The implementation uses the public source code provided by the 
% authors as a guideline and has an iterative structure not explained
% in the paper. The input parameters other than image and trimap 
% are optional. 
% - Maximum Manhattan distance of trimming is determined by iterCnt
%   such that maxManhDist = sum(1:iterCnt).
% - paramU determines the (maximum) color threshold in the iterations.
% - paramD determines how much this threshold is lowered as the
%   iterations progress.

function trimap = trimmingFromKnownUnknownEdges(image, trimap, paramU, paramD, iterCnt)

    if ~exist('iterCnt', 'var') || isempty(iterCnt)
        iterCnt = 9;
    end
    if ~exist('paramD', 'var') || isempty(paramD)
        paramD = 1 / 256;
    end
    if ~exist('paramU', 'var') || isempty(paramU)
        paramU = 9 / 256;
    end

    image = im2double(image);
    trimap = im2double(trimap);
    bg = (trimap < 0.2);
    fg = (trimap > 0.8);
    paramD = paramU - paramD;
    
    for i = 1 : iterCnt
        iterColorThresh = paramU - i * paramD / iterCnt; % color threshold = paramU - iterNo * (paramU - paramD) / maxIter
        trimap = LabelExpansion(image, trimap, i, iterColorThresh); % distance threshold 1 to iterCnt
    end
end

function [extendedTrimap] = LabelExpansion(image, trimap, maxDist, colorThresh) 
    [h, w, ~] =  size(image);

    fg = trimap > 0.8;
    bg = trimap < 0.2;    
    knownReg = (bg | fg);
    extendedTrimap = trimap;

    searchReg= ((imdilate(fg, ones(2 * maxDist + 1)) & ~fg) | (imdilate(bg, ones(2 * maxDist + 1)) & ~bg));
    [cols, rows] = meshgrid(1 : w, 1 : h);
    cols = cols(searchReg(:));
    rows = rows(searchReg(:));

    winCenter = (2 * maxDist) / 2 + 1;
    distPlane = repmat((1 : 2 * maxDist + 1)', [1, 2 * maxDist + 1])';
    distPlane = sqrt((distPlane - winCenter) .^ 2 + (distPlane' - winCenter) .^ 2);

    for pixNo = 1 : size(cols, 1)
        r = rows(pixNo);
        c = cols(pixNo);
        minR = max(r - maxDist, 1); % pixel limits
        minC = max(c - maxDist, 1);
        maxR = min(r + maxDist , h);
        maxC = min(c + maxDist, w);
        winMinR = winCenter - (r - minR); % pixel limits in window
        winMinC = winCenter - (c - minC);
        winMaxR = winCenter + (maxR - r);
        winMaxC = winCenter + (maxC - c);

        pixColor = image(r, c, :);
        imgWin = image(minR : maxR, minC : maxC, :); % colors
        trimapWin = trimap(minR : maxR, minC : maxC);

        winColorDiff = imgWin(:, :, 1) - pixColor(1);
        winColorDiff(:, :, 2) = imgWin(:, :, 2) - pixColor(2);
        winColorDiff(:, :, 3) = imgWin(: ,:, 3) - pixColor(3);
        winColorDiff = sqrt(sum(winColorDiff .* winColorDiff, 3));
        
        candidates= (winColorDiff < colorThresh) & knownReg(minR : maxR, minC : maxC); % known pixels under thresh
        if sum(candidates(:)) > 0
            distWin = distPlane(winMinR : winMaxR, winMinC : winMaxC); % distance plane
            distWin = distWin(candidates); % distances of known
            [~, minDistInd] = min(distWin); % location of minimum
            trimapWin = trimapWin(candidates);
            extendedTrimap(r, c) = trimapWin(minDistInd);
        end
    end

end
