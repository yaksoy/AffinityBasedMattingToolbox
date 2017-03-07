
% Local Linear Embedding
% This function implements the weight computation defined in
% Sam T. Roweis, Lawrence K. Saul, "Nonlinear Dimensionality 
% Reduction by Local Linear Embedding", Science, 2000.
% 'w' is the weights for representing the row-vector 'pt' in terms
% of the dimensions x neighborCount matrix 'neighbors'.
% 'conditionerMult' is the multiplier of the identity matrix added
% to the neighborhood correlation matrix before inversion.

function w = localLinearEmbedding(pt, neighbors, conditionerMult)
    % each column of neighbors represent a neighbor, each row a dimension
    % pt is a row vector
    corr = neighbors' * neighbors + conditionerMult * eye(size(neighbors, 2));
    corrInv = inv(corr);
    ptDotN = neighbors' * pt;
    alpha = 1 - sum(corrInv * ptDotN);
    beta = sum(corrInv(:));
    lagrangeMult = alpha / beta;
    w = corrInv * (ptDotN + lagrangeMult);
end