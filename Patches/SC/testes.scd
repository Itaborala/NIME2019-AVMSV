s.boot



s.scope

{A2K.kr(SinOsc.ar)}.plot
Record


(thisProcess.platform.recordingsDir +"fds"

s.makeWindow

{SinOsc.ar(440, SinOsc.ar(440))}.play
{SinOsc.ar(440, PlayBuf.ar(2, 1) +1.75)}.play



{SinOsc.ar(440, A2K.kr(SinOsc.ar(440)))}.play
{SinOsc.ar(440, A2K.kr(PlayBuf.ar(2, 1)))}.play

440/64
{SinOsc.ar(440, SinOsc.ar(6.875))}.play
{SinOsc.ar(440, PlayBuf.kr(2, 1))}.play




440/64

j = Buffer.read(s, "/home/itaborala/.local/share/SuperCollider/Recordings/SC_190522_115323.aiff")

{PlayBuf.ar(2, 1)}.play

s.record(duration: 5);

{SinOsc.kr(1).poll}.play;


(
v = Signal.sineFill(128, 1.0/[1,2,3,4,5,6]);
b = Buffer.alloc(s, 128);
)
b.plot


(

b.loadCollection(v, action: {|buf| x = { PlayBuf.ar(buf.numChannels, buf, BufRateScale.kr(buf), loop: 1)* 0.2 }.play;});

)

x.free; b.free;
 [1, 2, 3, 4, 5, 6, 2, 2, 3, 1, 3, 4, 5, 6 , 4, 3]/6

b = Buffer.alloc(s,16);
b.setn(0, [1, 2, 3, 4, 5, 6, 2, 2, 3, 1, 3, 4, 5, 6 , 4, 3]/6);