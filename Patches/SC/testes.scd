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



~fftbuf = Buffer.alloc(s, 2048);
~cepbuf = Buffer.alloc(s, 1024);

(

x = {var son, chain, cepsch;

    // You might like to try uncommenting these different source signals:
    son = WhiteNoise.ar;
    //son = Impulse.ar(150);
    //son = SinOsc.ar(440);
    //son = SinOsc.ar([150, 1450, 7203, 12010]).mean;

    // Or these filters:
    son = MoogFF.ar(son, 5350) * 5;
    //son = son + DelayN.ar(son, 0.003, 0.003);

    chain = FFT(~fftbuf, son, wintype: 1);

    cepsch = Cepstrum(~cepbuf, chain);

    // PV_BrickWall can act as a low-pass filter, or here, as a wol-pass lifter...
    // ...in practical terms, produces a smoothed version of the spectrum
    cepsch = PV_BrickWall(cepsch, -0.95);

    ICepstrum(cepsch, ~fftbuf);

    // We'll stop the unit after 1 second, the results are visible quickly enough
    Line.kr(1,0,1, doneAction: 2);

    son * 0.1
}.play;

)

// A convenience function to plot magnitudes:
~plotmags = {|buf, lbl| buf.loadToFloatArray(action:{|data| {data[0,2..]  .max(0.000001)  .log.normalize  .plot(lbl)}.defer})};

~plotmags.(~cepbuf, "cepstrum");
~plotmags.(~fftbuf, "liftered (smoothed) spectrum");

[~fftbuf, ~cepbuf].do(_.free);