function augmented = augmentIris(img)
% augmentIris  4 varyant uretir (hizli mod)
    augmented = cell(1, 4);
    augmented{1} = img;
    augmented{2} = fliplr(img);
    augmented{3} = imrotate(img,  7, 'bilinear', 'crop');
    augmented{4} = imrotate(img, -7, 'bilinear', 'crop');
end
