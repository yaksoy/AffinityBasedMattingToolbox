
% RGB normal distributions fit to colors around each pixel

function [meanImage, covarMat] = localRGBnormalDistributions(image, windowRadius, epsilon)

    if ~exist('windowRadius', 'var') || isempty(windowRadius)
        windowRadius = 1;
    end
    if ~exist('epsilon', 'var') || isempty(epsilon)
        epsilon = 1e-8;
    end

    [h, w, ~] = size(image);
    N = h * w;
    windowSize = 2 * windowRadius + 1;

    meanImage = imboxfilt(image, windowSize);
    covarMat = zeros(3, 3, N);

    for r = 1 : 3
        for c = r : 3
            temp = imboxfilt(image(:, :, r).*image(:, :, c), windowSize) - meanImage(:,:,r) .*  meanImage(:,:,c);
            covarMat(r, c, :) = temp(:);
        end
    end

    for i = 1 : 3
        covarMat(i, i, :) = covarMat(i, i, :) + epsilon;
    end

    for r = 2 : 3
        for c = 1 : r - 1
            covarMat(r, c, :) = covarMat(c, r, :);
        end
    end

end