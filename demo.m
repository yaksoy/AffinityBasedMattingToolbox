
image = imread('Training4.png');
trimap = imread('Training4Trimap.png');

% Closed-form matting
a_cf = closedFormMatting(image, trimap);
% Some alternatives:
% a_ifm = informationFlowMatting(image, trimap);
% a_knn = KNNMatting(image, trimap);

% Get the parameter struct and edit for customization if desired
params = getMattingParams('IFM');
params.useKnownToUnknown = 0;
% params.iu_xyw = 0.1;
% params.loc_mult = 3;
a_ifm = informationFlowMatting(image, trimap, params);

% Trim the trimap
trimmed = patchBasedTrimming(image, trimap);
% An alternative:
% trimmed = trimmingFromUnknownToKnownEdges(image, trimap);

% Run K-to-U information flow to get a rough alpha and confidences
[alphaHat, conf] = knownToUnknownColorMixture(image, trimmed);

% Refine alphaHat shared matting
a_sm_ref = sharedMattingMatteRefinement(image, trimmed, alphaHat, conf);
% Alternative:
% a_ifm_ref = informationFlowMatteRefinement(image, trimmed, alphaHat, conf);