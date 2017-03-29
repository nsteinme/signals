function [h] = fromSignal(packetSignal, sampleRate, bufferMax, nChannels, devIdx)
%AUDSTREAM.FROMSIGNAL Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  bufferMax = 2;
end

if nargin < 4 || isempty(nChannels)
  nChannels = 2;
end

if nargin < 5 || isempty(devIdx)
  id = audstream.open(sampleRate, nChannels);
else
  id = audstream.open(sampleRate, nChannels, devIdx);
end

audstream.start(id);
listener = packetSignal.onValue(fun.partial(@audstream.throttlePost, id,...
  bufferMax));
h = TidyHandle(@cleanup);

  function cleanup()
    disp('cleaning up audio stream');
    audstream.close(id);
    listener = [];
  end

end

