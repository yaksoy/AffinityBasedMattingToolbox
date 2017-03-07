
function Lap = affinityMatrixToLaplacian(aff)
    N = size(aff, 1);
    Lap = spdiags(sum(aff, 2), 0 , N, N) - aff;
end