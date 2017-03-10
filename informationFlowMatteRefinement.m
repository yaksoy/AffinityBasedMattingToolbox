
% Information-Flow Matte Refinement
% This function implements the matte refinement approach described in
% Yagiz Aksoy, Tunc Ozan Aydin, Marc Pollefeys, "Designing Effective 
% Inter-Pixel Information Flow for Natural Image Matting", CVPR, 2017.
% 'alphaHat' and 'confidences' parameters are typically obtained by a
% sampling-based natural matting algorithm. 'confidences' is filled by
% ones if not provided. Optional input parameter 'params' can be 
% customized by editing the default values in the struct returned 
% by 'getMattingParams('IFM').
% - **_K parameters represent the number of nonlocal neighbors found
%   for color mixture,  and intra-U flows, while **_xyw define the effect of
%   spatial proximity.
% - **_mult define the weight of each information flow. 
% - loc_*** define the parameters for the matting Laplacian.
% - refinement_mult determines how much trust is given to the initial
%   alpha estimation

function alpha = informationFlowMatteRefinement(image, trimap, alphaHat, confidences, params, suppressMessages)
    abmtSetup
    tic;
    if ~exist('confidences', 'var') || isempty(confidences)
        confidences = ones(size(alphaHat(:,:,1)));
    end
    if ~exist('params', 'var') || isempty(params)
        params = getMattingParams('IFM');
    end
    if ~exist('suppressMessages', 'var') || isempty(suppressMessages)
        suppressMessages = false;
    end
    if(~suppressMessages) display('Matte refinement via Information-Flow Matting...'); end

    image = im2double(image);
    trimap = im2double(trimap(:,:,1));
    alphaHat = im2double(alphaHat(:,:,1));

    % Compute L_IFM
    unk = trimap < 0.8 & trimap > 0.2;
    dilUnk = imdilate(unk, ones(3, 3));
    if(~suppressMessages) display('     Computing color mixture flow...'); end
    Lap = affinityMatrixToLaplacian(colorMixtureAffinities(image, params.cm_K, dilUnk, [], params.cm_xyw));
    Lap = params.cm_mult * (Lap' * Lap);
    if(~suppressMessages) display('     Computing matting Laplacian...'); end
    Lap = Lap + params.loc_mult * affinityMatrixToLaplacian(mattingAffinity(image, dilUnk, params.loc_win, params.loc_eps));
    if(~suppressMessages) display('     Computing intra-U flow...'); end
    Lap = Lap + params.iu_mult * affinityMatrixToLaplacian(colorSimilarityAffinities(image, params.iu_K, unk, unk, params.iu_xyw));

    if(~suppressMessages) display('     Solving for alphas...'); end
    alpha = solveForAlphas(Lap, trimap, params.lambda, params.usePCGtoSolve, alphaHat, confidences, params.refinement_mult);

    alpha = reshape(alpha, [size(image, 1), size(image, 2)]);

    dur = toc;
    if(~suppressMessages) display(['Done. It took ' num2str(dur) ' seconds.']); end
end
