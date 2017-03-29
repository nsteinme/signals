function [img, sz] = rgba(colour, alpha)
%vis.rgba Summary of this function goes here
%   Detailed explanation goes here

h = max(size(colour, 1), size(alpha, 1));
w = max(size(colour, 2), size(alpha, 2));
sz = [w h];

colour = uint8(round(255*colour));
alpha = uint8(round(255*alpha));

if ~isscalar(colour) && size(colour, 3) == 1 % overall luminance specified
  colour = repmat(colour, [1, 1, 3]); % replicate to rgb
end

img = zeros(h, w, 4, 'uint8');

img(:,:,1:3) = colour;
img(:,:,4) = alpha;
img = permute(img, [3 2 1]);
img = img(:);

end

