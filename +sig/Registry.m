classdef Registry < StructRef
  %SIG.REGISTRY Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    EntryLogs
    ClockFun
  end
  
  methods
    function obj = SignalsExp(clockFun)
      if nargin < 1
        obj.ClockFun = @GetSecs;
      else
        obj.ClockFun = clockFun;
      end
    end

    function value = entryAdded(this, name, value)
      % all event entries should be signals, so let's turn them into
      % logging signals
      assert(isa(value, 'sig.Signal'));
%       fprintf('Signal %s registered\n', name);
      this.EntryLogs.(name) = value.log(this.ClockFun);
    end
    
    function s = logs(this, clockOffset)
      s = struct;
      evtsfields = fieldnames(this);
      for ii = 1:numel(evtsfields)
        eventname = evtsfields{ii};
        loggedSig = this.EntryLogs.(eventname);
        log = loggedSig.Node.CurrValue;
        s.([eventname 'Values']) = [log.value];
        s.([eventname 'Times']) = [log.time] - clockOffset;
      end
    end
  end
  
end

