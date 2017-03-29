function throttlePost(streamId, bufferMax, packet)
%AUDSTREAM.THROTTLEPOST Summary of this function goes here
%   Detailed explanation goes here

usedSlots = audstream.info(streamId);
if usedSlots < bufferMax
%   if size(packet, 1) == 1
%     packet = repmat(packet, 2, 1);
%   end
  audstream.post(streamId, packet);
end

end

