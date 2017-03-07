
% Detect if the expected matte is a highly-transparent one
% This function implements the energy selection method described in
% Yagiz Aksoy, Tunc Ozan Aydin, Marc Pollefeys, "Designing Effective 
% Inter-Pixel Information Flow for Natural Image Matting", CVPR, 2017.
% This is a very simple histogram-based classifier.

function ht = detectHighlyTransparent(image, trimap)

    image = reshape(im2double(image), [size(image, 1) * size(image, 2), 3]);
    trimap = im2double(trimap(:,:,1));

    fg = trimap > 0.8;
    bg = trimap < 0.2;
    unk = ~(fg | bg);
    fg = fg & imdilate(unk, ones(20));
    bg = bg & imdilate(unk, ones(20));

    fgi = image(fg, :);
    bgi = image(bg, :);
    uni = image(unk, :);

    fgh = [imhist(fgi(:, 1), 10); imhist(fgi(:, 3), 10); imhist(fgi(:, 3), 10);] / sum(fg(:));
    bgh = [imhist(bgi(:, 1), 10); imhist(bgi(:, 3), 10); imhist(bgi(:, 3), 10);] / sum(bg(:));
    unh = [imhist(uni(:, 1), 10); imhist(uni(:, 3), 10); imhist(uni(:, 3), 10);] / sum(unk(:));

    weights = ([fgh bgh]' * [fgh bgh]) \ ([fgh bgh]' * unh);
    recError = [fgh bgh] * weights - unh;
    recError = sqrt(sum(recError(:) .* recError(:))) / size(recError(:), 1);

    ht = recError > 0.0099;

end