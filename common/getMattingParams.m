
% The returned struct can be customized before given as
% input to each of the methods available in this toolbox.
% algName should be:
% - 'IFM' for information flow matting
% - 'CF' for closed-form matting
% - 'KNN' for KNN matting
% - 'IFMRefinement' for information flow matte refinement
% - 'SharedMatting' for shared matting matte refinement

function params = getMattingParams(algName)
    if strcmpi(algName, 'IFM') || strcmpi(algName, 'InformationFlowMatting') || strcmpi(algName, 'IFMrefinement')
        params.lambda = 100;
        params.usePCGtoSolve = true;
        
        % Switch to use known-to-unknown information flow
        % -1: automatic selection, 0: do not use, 1: use
        params.useKnownToUnknown = -1;

        % Switch to apply edge-based trimming after matte estimation
        % The value reported in the paper is true, although we leave the
        % default as false here.
        params.mattePostTrim = false;

        % Color mixture information flow parameters
        params.cm_K = 20;
        params.cm_xyw = 1;
        params.cm_mult = 1;

        % Known-to-unknown information flow parameters
        params.ku_K = 7;
        params.ku_xyw = 10;
        params.ku_mult = 0.05;

        % Intra-unknown information flow parameters
        params.iu_K = 5;
        params.iu_xyw = 0.05;
        params.iu_mult = 0.01;

        % Local information flow parameters
        params.loc_win = 1;
        params.loc_eps = 1e-6;
        params.loc_mult = 1;

        % Parameter for Information Flow Matting matte refinement
        params.refinement_mult = 0.1;
    end
    if strcmpi(algName, 'ClosedForm') || strcmpi(algName, 'CF') || strcmpi(algName, 'ClosedFormMatting')...
                                  || strcmpi(algName, 'SharedMatting') || strcmpi(algName, 'SharedMattingRefinement')
        params.lambda = 100;
        params.usePCGtoSolve = false;

        % Matting Laplacian parameters
        params.loc_win = 1;
        params.loc_eps = 1e-7;

        % Parameter for Shared Matting matte refinement
        params.refinement_mult = 0.1;
    end
    if strcmpi(algName, 'KNN') || strcmpi(algName, 'KNNMatting')
        params.lambda = 1000;
        params.usePCGtoSolve = true;

        % Parameters for the neighbor selection
        params.knn_K = 20;
        params.knn_xyw = 1;
        params.knn_hsv = true;
    end
end