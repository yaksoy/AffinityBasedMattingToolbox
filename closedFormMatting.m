
% Closed-Form Matting
% This function implements the image matting approach described in
% Anat Levin, Dani Lischinski, Yair Weiss, "A Closed Form Solution to 
% Natural Image Matting", IEEE TPAMI, 2008.
% Optional input parameter 'params' can be customized by editing the 
% default values in the struct returned by 'getMattingParams('CF').
% - loc_*** define the parameters for the matting Laplacian.

function alpha = closedFormMatting(image, trimap, params, suppressMessages)
    abmtSetup
    tic;
    if ~exist('params', 'var') || isempty(params)
        params = getMattingParams('CF');
    end
    if ~exist('suppressMessages', 'var') || isempty(suppressMessages)
        suppressMessages = false;
    end
    if(~suppressMessages) display('Closed-Form Matting started...'); end

    image = im2double(image);
    trimap = im2double(trimap(:,:,1));

    % Compute matting Laplacian
    unk = trimap < 0.8 & trimap > 0.2;
    dilUnk = imdilate(unk, ones(2 * params.loc_win + 1));
    if(~suppressMessages) display('     Computing matting Laplacian...'); end
    Lap = affinityMatrixToLaplacian(mattingAffinity(image, dilUnk, params.loc_win, params.loc_eps));
    
    if(~suppressMessages) display('     Solving for alphas...'); end
    alpha = solveForAlphas(Lap, trimap, params.lambda, params.usePCGtoSolve);

    alpha = reshape(alpha, [size(image, 1), size(image, 2)]);

    dur = toc;
    if(~suppressMessages) display(['Done. It took ' num2str(dur) ' seconds.']); end
end
