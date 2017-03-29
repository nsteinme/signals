function elem = grating(t, grating, window)
%VIS.GRATINGELEM Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3 || isempty(window)
  window = 'gaussian';
end

if nargin < 2 || isempty(grating)
  grating = 'sinusoid';
end
elem = t.Node.Net.subscriptableOrigin('gabor');
elem.grating = grating;
elem.window = window;
elem.azimuth = 0;
elem.altitude = 0;
elem.sigma = [10 10];
elem.spatialFreq = 1/15;
elem.phase = 0;
elem.orientation = 0;
elem.contrast = 1;
elem.show = false;

elem.layers = elem.map(@makeLayers).flattenStruct();
end

function layers = makeLayers(newelem)
%% make a grating layer of the specified type
switch lower(newelem.grating)
  case {'sinusoid' 'sine' 'sin'}
    [gratingLayer, gratingImg] = vis.sinusoidLayer(newelem.azimuth,...
      newelem.spatialFreq, newelem.phase, newelem.orientation);
    gratingLayer.textureId = 'sinusoidGrating';
  case {'squarewave' 'square' 'sq'}
    [gratingLayer, gratingImg] = vis.squareWaveLayer(newelem.azimuth,...
      newelem.spatialFreq, newelem.phase, newelem.orientation);
    gratingLayer.textureId = 'squareWaveGrating';
  otherwise
    error('Invalid grating type ''%s''', grating);
end
[gratingLayer.rgba, gratingLayer.rgbaSize] = vis.rgba(gratingImg, 1);
gratingLayer.blending = 'destination';
l = 0.5 - 0.5*newelem.contrast;
h = 0.5 + 0.5*newelem.contrast;
gratingLayer.minColour = l.*[1 1 1 0];
gratingLayer.maxColour = [h.*ones(1, 3) 1];
gratingLayer.show = newelem.show;

%% make a stencil layer using a window of the specified type
if ~strcmpi(newelem.window, 'none')
  switch lower(newelem.window)
    case {'gaussian' 'gauss'}
      [winLayer, winImg] = vis.gaussianLayer(...
        [newelem.azimuth; newelem.altitude], newelem.sigma);
      winLayer.textureId = 'gaussianStencil';
    otherwise
      error('Invalid window type ''%s''', window);
  end
  [winLayer.rgba, winLayer.rgbaSize] = vis.rgba(0, winImg);
  winLayer.blending = 'none';
  winLayer.colourMask = [false false false true];
  winLayer.show = newelem.show;
else % no window
  winLayer = [];
end

% window layer rendered first like a stencil
layers = [winLayer, gratingLayer];
end