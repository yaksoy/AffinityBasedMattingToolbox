
% Shared Matting Matte Refinement
% This function implements the matte refinement approach described in
% Eduardo S. L. Gastal, Manuel M. Oliveira, "Shared Sampling for 
% Real-Time Alpha Matting", Computer Graphics Forum, 2010.
% 'alphaHat' and 'confidences' parameters are typically obtained by a
% sampling-based natural matting algorithm. 'confidences' is filled by
% ones if not provided. Optional input parameter 'params' can be 
% customized by editing the default values in the struct returned 
% by 'getMattingParams('SharedMatting').
% - loc_*** define the parameters for the matting Laplacian.
% - refinement_mult determines how much trust is given to the initial
%   alpha estimation

function alpha = sharedMattingMatteRefinement(image, trimap, alphaHat, confidences, params, suppressMessages)
    abmtSetup
    tic;
    if ~exist('confidences', 'var') || isempty(confidences)
        confidences = ones(size(alphaHat(:,:,1)));
    end
    if ~exist('params', 'var') || isempty(params)
        params = getMattingParams('SharedMatting');
    end
    if ~exist('suppressMessages', 'var') || isempty(suppressMessages)
        suppressMessages = false;
    end
    if(~suppressMessages) display('Matte refinement via Shared Matting...'); end

    image = im2double(image);
    trimap = im2double(trimap(:,:,1));
    alphaHat = im2double(alphaHat(:,:,1));

    % Compute matting Laplacian
    unk = trimap < 0.8 & trimap > 0.2;
    dilUnk = imdilate(unk, ones(3, 3));
    if(~suppressMessages) display('     Computing matting Laplacian...'); end
    Lap = affinityMatrixToLaplacian(mattingAffinity(image, dilUnk, params.loc_win, params.loc_eps));
    
    if(~suppressMessages) display('     Solving for alphas...'); end
    alpha = solveForAlphas(Lap, trimap, params.lambda, params.usePCGtoSolve, alphaHat, confidences, params.refinement_mult);

    alpha = reshape(alpha, [size(image, 1), size(image, 2)]);
    
    dur = toc;
    if(~suppressMessages) display(['Done. It took ' num2str(dur) ' seconds.']); end
end
