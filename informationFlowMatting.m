
% Information-Flow Matting
% This function implements the image matting approach described in
% Yagiz Aksoy, Tunc Ozan Aydin, Marc Pollefeys, "Designing Effective 
% Inter-Pixel Information Flow for Natural Image Matting", CVPR, 2017.
% Optional input parameter 'params' can be customized by editing the 
% default values in the struct returned by 'getMattingParams('IFM').
% - The parameter useKnownToUnknown makes the decision to use
%   E_1 or E_2 as defined in the paper. A negative number means 
%   automatic selection.
% - **_K parameters represent the number of nonlocal neighbors found
%   for color mixture, K-to-U and intra-U flows, while **_xyw define the 
%   effect of spatial proximity.
% - **_mult define the weight of each information flow.
% - loc_*** define the parameters for the matting Laplacian.
% - mattePostTrim determines if edge-based trimming should be applied
%   as a post-processing to the estimated alpha. Here the defult is 
%   false, but in the original paper it is reported to be 'true'.

function alpha = informationFlowMatting(image, trimap, params, suppressMessages)
    abmtSetup
    tic;
    if ~exist('params', 'var') || isempty(params)
        params = getMattingParams('IFM');
    end
    if ~exist('suppressMessages', 'var') || isempty(suppressMessages)
        suppressMessages = false;
    end
    if(~suppressMessages) display('Information-Flow Matting started...'); end

    image = im2double(image);
    trimap = im2double(trimap(:,:,1));

    % Decide to use the K-to-U flow
    if params.useKnownToUnknown < 0
        useKU = ~detectHighlyTransparent(image, trimap);
    else
        useKU = params.useKnownToUnknown > 0;
    end
    if(~suppressMessages)
        if useKU
            display('     Known-to-unknown information flow will be used.');
        else
            display('     Known-to-unknown information flow will NOT be used.');
        end
    end

    if params.mattePostTrim || useKU
        % Trimap trimming for refining kToU flow or final matte
        if(~suppressMessages) display('     Trimming trimap from edges...'); end
        edgeTrimmed = trimmingFromKnownUnknownEdges(image, trimap);
    end

    % Compute L_IFM
    unk = trimap < 0.8 & trimap > 0.2;
    dilUnk = imdilate(unk, ones(2 * params.loc_win + 1));
    if(~suppressMessages) display('     Computing color mixture flow...'); end
    Lap = affinityMatrixToLaplacian(colorMixtureAffinities(image, params.cm_K, unk, [], params.cm_xyw));
    Lap = params.cm_mult * (Lap' * Lap);
    if(~suppressMessages) display('     Computing matting Laplacian...'); end
    Lap = Lap + params.loc_mult * affinityMatrixToLaplacian(mattingAffinity(image, dilUnk, params.loc_win, params.loc_eps));
    if(~suppressMessages) display('     Computing intra-U flow...'); end
    Lap = Lap + params.iu_mult * affinityMatrixToLaplacian(colorSimilarityAffinities(image, params.iu_K, unk, unk, params.iu_xyw));

    if useKU
        % Compute kToU flow
        if(~suppressMessages) display('     Trimming trimap using patch similarity...'); end
        patchTrimmed = patchBasedTrimming(image, trimap, [], [], [], 5); % We set K = 5 here for better computation time
        if(~suppressMessages) display('     Computing K-to-U flow...'); end
        [kToU, kToUconf] = knownToUnknownColorMixture(image, patchTrimmed, params.ku_K, params.ku_xyw);
        kToU(edgeTrimmed < 0.2) = 0;
        kToU(edgeTrimmed > 0.8) = 1;
        kToUconf(edgeTrimmed < 0.2) = 1;
        kToUconf(edgeTrimmed > 0.8) = 1;
        if(~suppressMessages) display('     Solving for alphas...'); end
        alpha = solveForAlphas(Lap, trimap, params.lambda, params.usePCGtoSolve, kToU, kToUconf, params.ku_mult);
    else
        if(~suppressMessages) display('     Solving for alphas...'); end
        alpha = solveForAlphas(Lap, trimap, params.lambda, params.usePCGtoSolve);
    end

    alpha = reshape(alpha, [size(image, 1), size(image, 2)]);
    
    if params.mattePostTrim
        alpha(edgeTrimmed < 0.2) = 0;
        alpha(edgeTrimmed > 0.8) = 1;
    end

    dur = toc;
    if(~suppressMessages) display(['Done. It took ' num2str(dur) ' seconds.']); end
end
