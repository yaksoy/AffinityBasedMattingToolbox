
% KNN Matting
% This function implements the image matting approach described in
% Qifeng Chen, Dingzeyu Li, Chi-Keung Tang, "KNN Matting", IEEE 
% TPAMI, 2013.
% Optional input parameter 'params' can be customized by editing the 
% values in the struct returned by 'getMattingParams('CF').
% - knn_K defines the number of nonlocal neighbors
% - knn_xyw defines the weight of the spatial coordinates in KNN search
% - knn_hsv defines the color space (RGB or HSV) for KNN search

function alpha = KNNMatting(image, trimap, params, suppressMessages)
    abmtSetup
    tic;
    if ~exist('params', 'var') || isempty(params)
        params = getMattingParams('KNN');
    end
    if ~exist('suppressMessages', 'var') || isempty(suppressMessages)
        suppressMessages = false;
    end
    if(~suppressMessages) display('KNN Matting started...'); end

    image = im2double(image);
    trimap = im2double(trimap(:,:,1));

    % Compute KNN affinities
    unk = trimap < 0.8 & trimap > 0.2;
    dilUnk = imdilate(unk, ones(3, 3));
    if(~suppressMessages) display('     Computing KNN affinities...'); end
    Lap = affinityMatrixToLaplacian(colorSimilarityAffinities(image, params.knn_K, [], [], params.knn_xyw, params.knn_hsv));
    
    if(~suppressMessages) display('     Solving for alphas...'); end
    alpha = solveForAlphas(Lap, trimap, params.lambda, params.usePCGtoSolve);

    alpha = reshape(alpha, [size(image, 1), size(image, 2)]);

    dur = toc;
    if(~suppressMessages) display(['Done. It took ' num2str(dur) ' seconds.']); end
end
