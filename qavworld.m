function qavworld(t, evts, p, vs, inputs, outputs, audio)

% otherwise identical to quiescentAudioVisWorld, except that stim comes on
% first and then cue to tell the animal it can move & give response

audioSR = 192e3; % fixed for now

numPinkNoiseSamples = audioSR*p.pinkNoiseDur;
pinkNoiseSamples = p.pinkNoiseAmplitude*numPinkNoiseSamples.map(@pinknoise);
audio.pinkNoise = pinkNoiseSamples.at(evts.newTrial);

% make some short names
wheel = inputs.wheel.skipRepeats();

%% ITI & pre-stim quiescent period
% inter-trial delay that gets taken from an exponential distribution, 
% during which no quiescence is required
interTrialDelayEnd  = evts.newTrial.delay(p.interTrialDelay.map(@rnd.uni));

preStimPeriod       = p.preStimQuiescentPeriod.at(interTrialDelayEnd).map(@rnd.uni);

%% onset cues and stimulus presentations
% set cue to come on at the end of quiescent period
stimuliOn        = sig.quiescenceWatch(preStimPeriod, t, wheel, p.quiescThreshold);

stimQuiescPeriod = p.stimQuiescentPeriod.at(stimuliOn).map(@(x)min(x(1) + exprnd(x(3)), x(2)));
cueOn            = sig.quiescenceWatch(stimQuiescPeriod, t, wheel, p.quiescThreshold); 

% auditory cue parameters
onsetToneSamples = p.onsetToneAmplitude*...
  mapn(p.onsetToneFreq, p.onsetToneDuration, audioSR, p.onsetToneRampDuration, @aud.pureTone);
audio.onsetTone = onsetToneSamples.at(cueOn);         
% visual cue parameters defined within the visual stimuli section

interactiveOn   = cueOn.delay(p.interactiveDelay);

%% wheel position to stimulus displacement
wheelOrigin = wheel.at(interactiveOn);
targetDisplacement = p.wheelGain*(wheel - wheelOrigin); 

%% response at threshold detection
responseTimeOver = (t - t.at(interactiveOn)) > p.responseWindow;

threshold = interactiveOn.setTrigger(...
  abs(targetDisplacement) >= abs(p.targetAzimuth) | responseTimeOver);
% negative because displacement is opposite sign to initial position
response = cond(...
  responseTimeOver, 0,...
  true, -sign(targetDisplacement));   % response will be 0 when no go, -1 when left (azimuth = -30?) 1 when right
response = response.at(threshold);

%% feedback
feedback = 2*(p.correctResponse == response)  - 1;
feedback = feedback.at(threshold);
audio.noiseBurst = at(p.noiseBurstAmp*p.noiseBurstDur.map(@(dur)randn(2,dur*audioSR)), feedback < 0);
reward = p.rewardSize.at(feedback > 0); 
outputs.reward = reward;

%% vis stimulus position

stimOff = threshold.delay(cond(...
  feedback > 0, p.rewardDur, ...
  feedback < 0, p.noiseBurstDur));
stimOff2 = threshold.delay(cond(...
  feedback > 0, p.rewardDur, ...
  feedback < 0, p.noiseBurstDur));            
stimOff3 = threshold.delay(cond(...
  feedback > 0, p.rewardDur, ...
  feedback < 0, 0.1));            % EJ addition on 04/04/2016 - to be used for the cue stimulus determination, so when the trial is wrong, the cue in the middle disappears after 0.1 seconds rather than syaing for p.noiseBurstDur

% EJ addition 28/08/2015
stimPresent = stimuliOn.to(stimOff3);

azimuth = p.targetAzimuth + cond(...
  stimuliOn.to(interactiveOn), 0,... % no offset during fixed period
  interactiveOn.to(threshold), targetDisplacement,...%offset by wheel
  threshold.to(stimOff3),  -response*abs(p.targetAzimuth));

%% auditory stimulus

% pipPlaying = stimuliOn.to(StimOff);
freqPosition = p.pipHomeFreq*2.^(-0.5*p.pipFreqGain*azimuth/abs(p.targetAzimuth));
% todo: sample interval can be signal
sampler = skipRepeats(floor(p.pipRate*t)); % sampler will update at pipRate
pipFreq = freqPosition.at(sampler).keepWhen(stimPresent);
pipSamples = p.pipAmplitude*mapn(...
  pipFreq, p.pipDuration, audioSR, p.pipRampDuration, @aud.pureTone);
audio.pips = pipSamples.keepWhen(stimPresent);

%% visual stimulus
vistarget = vis.grating(t, 'sinusoid', 'gaussian');
vistarget.altitude          = p.targetAltitude;
vistarget.sigma             = p.targetSigma;
vistarget.spatialFrequency  = p.targetSpatialFrequency;
vistarget.phase             = 2*pi*evts.newTrial.map(@(v)rand); % random phase on each trial
vistarget.orientation       = p.targetOrientation;
vistarget.contrast          = p.targetContrast;
vistargetAzimuth = p.targetAzimuth + cond(...
  stimuliOn.to(interactiveOn), 0,... % no offset during fixed period
  interactiveOn.to(threshold),   targetDisplacement,...%offset by wheel
  threshold.to(stimOff),    -response*abs(p.targetAzimuth));%final response
vistarget.azimuth           = vistargetAzimuth;
vistarget.show              = stimuliOn.to(stimOff2);  
vs.target = vistarget; % put target in visual stimuli set

% visual cue parameters
% keep all settings the same as for stimulus, apart from its own contrast value
viscue = vis.grating(t, 'sinusoid', 'gaussian');
viscue.altitude          = p.targetAltitude;
viscue.sigma             = p.targetSigma;
viscue.spatialFrequency  = p.targetSpatialFrequency;
viscue.phase             = 2*pi*evts.newTrial.map(@(v)rand); % random phase on each trial
viscue.orientation       = p.targetOrientation;
viscue.contrast          = p.cueContrast;
viscue.azimuth           = p.cueAzimuth;
viscue.show              = cueOn.to(stimOff3);
vs.cue = viscue;

%% misc
nextCondition = feedback > 0;
evts.endTrial = nextCondition.at(stimOff);

% we want to save these so we put them in events with appropriate names
evts.stimuliOn      = stimuliOn;
evts.stimuliOff     = stimOff;
evts.interactiveOn  = interactiveOn;
evts.targetAzimuth  = vistargetAzimuth;
evts.pipFreq        = pipFreq;
evts.response       = response;
evts.feedback       = feedback;
evts.totalReward    = reward.scan(@plus, 0).map(fun.partial(@sprintf, '%.1fµl'));

end