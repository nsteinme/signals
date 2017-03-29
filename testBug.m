clearvars
n = sig.Net;
t = n.origin('thr');
thr = n.origin('thr');
fb = n.origin('f');
on = n.origin('on');
off = thr.delay(cond(...
  fb > 0, 0,...
  fb < 0, 0));


v1 = vis.grating(t, 'sinusoid', 'gaussian');
v2 = vis.grating(t, 'sinusoid', 'gaussian');
v1.show = on.to(off);
v2.show = on.to(off);
%%
lh = [
  show1.onValue(@(v)fprintf('show1=''%s''\n', toStr(v)))
  show2.onValue(@(v)fprintf('show2=''%s''\n', toStr(v)))]
%%
on.post(1);
%%
fb.post(1);
thr.post(1);
%%
runSchedule(n)