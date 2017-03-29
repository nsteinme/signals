classdef Registry < sig.Registry
  %audstream.Registry Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Handles
  end
  
  properties (SetAccess = private)
    SampleRate
    NChannels
    DevIdx
  end
  
  methods
    function this = Registry(sampleRate, nChannels, devIdx)
      if nargin < 2
        nChannels = 2;
      end
      if nargin < 3
        devIdx = -1; % -1 means use system default audio device
      end
      this.SampleRate = sampleRate;
      this.NChannels = nChannels;
      this.DevIdx = devIdx;
    end

    function value = entryAdded(this, name, value)
      this.Handles = ...
        [this.Handles audstream.fromSignal(value, this.SampleRate, 2, this.NChannels, this.DevIdx)];
    end
  end
  
end

