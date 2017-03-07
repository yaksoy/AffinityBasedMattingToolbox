
% Constructs and solves the linear system

function alphas = solveForAlphas(Lap, trimap, lambda, usePCG, alphaHat, conf, aHatMult)
    if ~exist('usePCG', 'var') || isempty(usePCG)
        usePCG = true;
    end
    [h, w, ~] = size(trimap);
    N = h * w;
    known = trimap > 0.8 | trimap < 0.2;
    A = lambda * spdiags(double(known(:)), 0, N, N);
    if exist('alphaHat', 'var')
        if ~exist('conf', 'var') || isempty(conf)
            conf = ones(size(alphaHat));
        end
        if ~exist('aHatMult', 'var') || isempty(aHatMult)
            aHatMult = 0.1;
        end
        conf(known(:)) = 0;
        A = A + aHatMult * spdiags(conf(:), 0, N, N);
        b = A * alphaHat(:);
    else
        b = A * double(trimap(:) > 0.8);
    end
    A = A + Lap;
    if usePCG
        [alphas, ~] = pcg(A, b, [], 2000);
    else
        alphas = A \ b;
    end
    alphas(alphas < 0) = 0;
    alphas(alphas > 1) = 1;
end