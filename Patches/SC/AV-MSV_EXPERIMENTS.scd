(
Server.default = s = Server.local;
s.options.sampleRate_(48000);
s.options.numOutputBusChannels = 6;
s.options.numInputBusChannels = 2;


//"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");
"SC_JACK_DEFAULT_OUTPUTS".setenv("Volume_Master:input_1,Volume_Master:input_2,Volume_Master:input_3,Volume_Master:input_4,Volume_Master:input_5,Volume_Master:input_6");


)
(
s.boot;
OpenObject.start
)

s.recSampleFormat_("int24");
s.quit;
s.makeGui;

//s.prepareForRecord("/Volumes/ALEX_BUCK_2T_USBC/MADRIGALE_A_SEI_VASI/PERFORMANCE/sabado.aif");
//s.record;
//s.stopRecording;
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////


~fftbuf = Buffer.alloc(s, 2048);
~cepbuf = Buffer.alloc(s, 1024);

(
x = {
    var son, chain, cepsch;

    // You might like to try uncommenting these different source signals:
    son = WhiteNoise.ar;
    //son = Impulse.ar(150);
    //son = SinOsc.ar(440);
    //son = SinOsc.ar([150, 1450, 7203, 12010]).mean;

    // Or these filters:
    //son = MoogFF.ar(son, 5350) * 5;
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
(
{
//var son, chain, cepsch;

// You might like to try uncommenting these different source signals:
~son = WhiteNoise.ar;
//son = Impulse.ar(150);
//son = SinOsc.ar(440);
//son = SinOsc.ar([150, 1450, 7203, 12010]).mean;

// Or these filters:
//son = MoogFF.ar(son, 5350) * 5;
//son = son + DelayN.ar(son, 0.003, 0.003);

~chain = FFT(~fftbuf, ~son, wintype: 1);

~cepsch = Cepstrum(~cepbuf, ~chain);

// PV_BrickWall can act as a low-pass filter, or here, as a wol-pass lifter...
// ...in practical terms, produces a smoothed version of the spectrum
~cepsch = PV_BrickWall(~cepsch, -0.95);

ICepstrum(~cepsch, ~fftbuf);

}.plot

)





// A convenience function to plot magnitudes:
~plotmags = {|buf, lbl| buf.loadToFloatArray(action:{|data| {data[0,2..]  .max(0.000001)  .log.normalize  .plot(lbl)}.defer})};

~plotmags.(~cepbuf, "cepstrum");
~plotmags.(~fftbuf, "liftered (smoothed) spectrum");

[~fftbuf, ~cepbuf].do(_.free);

Chromagram

(
{

var in, fft, chroma;

in = SinOsc.ar(440,0,0.1);
//in= SoundIn.ar;

fft = FFT(LocalBuf(2048), in);

chroma=Chromagram.kr(fft);

chroma.poll;

Out.ar(0,Pan2.ar(in));
}.play
)



//n TET display

n= 12; //19, 24

(
x = {

var in, fft, chroma;

in = SinOsc.ar(440,0,0.1);
//in= SoundIn.ar;

fft = FFT(LocalBuf(2048), in);

chroma=Chromagram.kr(fft, 2048, n);

//chroma=Chromagram.kr(fft, 2048, n, 36.midicps, 7, 1, 0.9);

Out.kr(0,chroma);
}.play;

c= Bus.new('control', 0, n);

)



//poll coefficients snapshot
c.getn(n,{arg val; {val.plot;}.defer});



//Continuous graphical display of Chromagram values; free routine before closing window

(
var ms;

w=Window.new((n.asString)++" chroma coefficients", Rect(200,400,n*20+50,300));

ms= MultiSliderView.new(w, Rect(10,10,n*20,280));

ms.value_(Array.fill(n,0.0));
ms.valueThumbSize_(20.0);
ms.indexThumbSize_(20.0);
ms.gap_(0);

w.front;

r= {

inf.do{

c.getn(n,{arg val; {ms.value_(val)}.defer});

0.04.wait; //25 frames per second
};

}.fork;

w.onClose = {
r.stop;
c.free;
x.free;
};

)



b.free;



//Bohlen-Pierce over 3 tritaves, normalized results per frame
(
{

var in, fft, chroma;

in = SinOsc.ar(440,0,0.1);
//in= SoundIn.ar;

fft = FFT(LocalBuf(2048), in);

chroma=Chromagram.kr(fft,2048,13,octaves:3,octaveratio:3,perframenormalize:1);

chroma.poll;

Out.ar(0,Pan2.ar(in));
}.play
)


OnsetStatistics

//[0] density (number of onsets in window)
//[1] mean IOI
//[2] variance IOI
​
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav")
​
//minimal example
(
{
    //var source = SoundIn.ar;
​
    var source = PlayBuf.ar(1,b,loop:1);

    var onsetanalysis =
    OnsetStatistics.kr(Onsets.kr(FFT(LocalBuf(512),source),0.125),2.0);
​
    onsetanalysis.poll(10);
​
    source
}.play;
)Dictionary


(
b = Dictionary.new;
PathName(~folder).entries.do{
	arg subfolder;
	b.add(
		subfolder.folderName.asSymbol ->
		Array.fill(
			subfolder.entries.size,
			{
				arg i;
				Buffer.read(s, subfolder.entries[i].fullPath);
			}
		)
	);
};
)

b[\ESTRUTURAS]
PathName(~folder).entries[0].entries.size
/////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// FUNCTIONS EXPERIMENTS SECTION /////////////////////////////////////

//--------------------------------------------------------------------------------------- Step 1

~folder = "../Sons/ESTRUTURAS/VOZ_LUANA/";
~folder = "../Sons";
//~folder = "../Sons/Vasos_Camila/;


(
var paths, soundPath;

~paths = List[];

//paths = Pipe.new("ls ../Sons/Vozes_Luana_BRC_Estudios/", "r");
paths = Pipe.new("ls " + ~folder, "r");


soundPath = paths.getLine;

while({soundPath.notNil}, {~paths = ~paths.add(soundPath); soundPath = paths.getLine;});

paths.close;

~paths;
)

//--------------------------------------------------------------------------------------- Step 1



~paths.size
~paths.wchoose(1/12!12)
~paths.wchoose([0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])

1/12!12

(var len;

len = ~paths.size;
k = Buffer.cueSoundFile(s, "../Sons/ESTRUTURAS/VOZ_LUANA/" +/+ ~paths.wchoose(1/len !len ), 0, 1);


)

(var len;

len = ~paths.size;
k = Buffer.read(s, "../Sons/ESTRUTURAS/VOZ_LUANA/" ++ ~paths.wchoose(1/len !len ));
k.close
)


k.plot
k.bufnum
k.close
y = { PlayBuf.ar(1, k.bufnum) }.play
x = { DiskIn.ar(1, k.bufnum) }.play;

{SinOsc.ar}.play

x.free
y.free
/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// SYNTHDEF EXPERIMENTS SECTION /////////////////////////////////////

OpenObject.start

(
SynthDef(\diskin, {

	Out.ar(\out.kr(0), DiskIn.ar(1, \bufnum.kr(0)));

}).add
)

(
y = Synth.new(\diskin);
n = { arg buf; y.addToHeadMsg(nil,  [\out, 0, \bufnum, buf.bufnum])};
)

(
var len;
len = ~paths.size;
k = Buffer.cueSoundFile(s, "../Sons/ESTRUTURAS/VOZ_LUANA/" +/+ ~paths.wchoose(1/len !len ), 0, 1, completionMessage: n);
)

k.close

MouseX

//--------- 6 Channels Version

(
SynthDef(\diskin6, {
	Out.ar(\out.kr(0), PanAz.ar(6, DiskIn.ar(1, \bufnum.kr(0)), 0.0));
}).add
)
basicNew
(
x = Synth.new(\diskin6);
m = { arg buf; x.addToHeadMsg(nil, [\bufnum, buf.bufnum])};
)
k
(
var len;
len = ~paths.size;
k = Buffer.cueSoundFile(s, "../Sons/ESTRUTURAS/VOZ_LUANA/" +/+ ~paths.wchoose(1/len !len ), 0, 1, completionMessage: m);
)
s.scope
k.close
//---------- Inserting static control

(
SynthDef(\diskin6, {

	Out.ar(\out.kr(0), PanAz.ar(6, DiskIn.ar(1, \bufnum.kr(0)), -1, orientation: \orientatio.kr(0.0) ));
}).add
)
(
x = Synth.new(\diskin6);
m = { arg buf; x.addToHeadMsg(nil, [\bufnum, buf.bufnum])};
)
(
var len;
len = ~paths.size;
k = Buffer.cueSoundFile(s, ~folder +/+ ~paths.wchoose(1/len !len ), 0, 1, completionMessage: m);
)

x.addToHeadMsg(nil, [\orientatio, {MouseX.kr(-2.0, 2.0)}])

x.set(\orientatio, -2.0)
//orientation channels: -3.0, 2.0, -0.99, 0.0, 1.0, 2.01

x.free
s.scope
k.close
map

//--------- Control with UGens using Buses and control Synths

//----------------Control Synthdef

(
SynthDef(\test, {
	Out.ar(\out.ar(0), SinOsc.ar(\freq.kr(440) ! 2));
}).add;
)
(
SynthDef(\modulator, {
	Out.kr(\out.kr(0), SinOsc.kr(\freq.kr(1)).range(440,600));
}).add;
)
~bus = Bus.control(s,1);
~testSynth = Synth(\test);
~modulatorSynth = Synth(\modulator, [out: ~bus]);
~testSynth.map(\freq, ~bus);



//-------------Node messaging

(
SynthDef("grain", {
    Out.ar(0, Line.kr(0.1, 0, 0.01, doneAction: Done.freeSelf) * FSinOsc.ar(12000))
}).send(s);
)

(
Routine({
    20.do({
        s.sendMsg("/s_new", "grain", -1);
        0.01.wait;
    })
}).play;
)

//--------Last diskin implementation


(
SynthDef(\diskin6, {

	Out.ar(\out.kr(0), PanAz.ar(6, DiskIn.ar(1, \bufnum.kr(0)), -1, orientation: \orientatio.kr(0.0) ));
}).add
)
(
x = Synth.basicNew(\diskin6);
m = { arg buf; x.addToHeadMsg(nil, [\bufnum, buf.bufnum])};
)
(
var len;
len = ~paths.size;

x = Synth.basicNew(\diskin6);
m = { arg buf; x.addToHeadMsg(nil, [\bufnum, buf.bufnum])};

k = Buffer.cueSoundFile(s, ~folder +/+ ~paths.wchoose(1/len !len ), 0, 1, completionMessage: m);
)

x.addToHeadMsg(nil, [\orientatio, {MouseX.kr(-2.0, 2.0)}])

x.set(\orientatio, -0.99)
x.set(\orientatio, -2.0)
//orientation channels: -3.0, 2.0, -0.99, 0.0, 1.0, 2.01

s.queryAllNodes
x.free
x.trace
s.scope
k.close
x
map

//-------------------Last Synthdef control implementation


(

SynthDef(\modulator, {
	Out.kr(\out.kr(0), SinOsc.kr(\freq.kr(1)).range(-3,3));
}).add;

SynthDef(\control_mouseXs1, {
	Out.kr(\out.kr(0), MouseX.kr(-1, 1000));
}).add;

)


(

~busModulator = Bus.control(s,1);
~modulatorSynth = Synth(\modulator, [\out, ~busModulator]);

)


(

~busMouseX = Bus.control(s, 2);
~mouseXSynth = Synth(\control_mouseXs1, [\out, ~busMouseX]);

)

//--------------------------- Close

(
x.free;
k.free;
)

(
~busModulator.free
~busMouseX.free
)




/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// EXPLORING AND TUTORIALS SECTION ////////////////////////////////////
~buz = Bus.audio(s, 6)
~buz.free

/////////////////////OpenObject Example

Quarks.install("OpenObject");
Quarks.install("sc3plugins");
Quarks.install("JITLibExtensions");
Quarks.gui

//puredata buffer example

s.boot

OpenObject.start

b= Buffer.read(s, "NIME2019-AVMSV/Sons/Vasos_Camila/ataques_vasos_01.wav")
b= Buffer.read(s, "NIME2019-AVMSV/Sons/ESTRUTURAS/VOZ_LUANA/SussurroMouseXY_01.wav")
(
SynthDef(\vasoread, { |bufnum, amp= 0, freq= 10, rate= 1, offset= 0, dur= 0.3, pan= 0|
	Out.ar(0, TGrains.ar(2, Impulse.ar(freq), bufnum, rate, offset*BufDur.ir(b), dur, pan, amp));
}).add;
)

x= Synth(\vasoread)
x.publish(\vasoX)

x.unpublish(\vasoX)

b.release;
b.free;

//////////////////////Terminal Unix Commands
"ls -l ../Sons/ESTRUTURAS/VOZ_LUANA".unixCmd
"ls -l".unixCmd
"ls -l ../Sons/Vozes_Luana_BRC_Estudios".unixCmd
"cd NIME2019-AVMSV/".unixCmd
"pwd".unixCmd
(
//var p, l,

d = "";

p = Pipe.new("ls -l", "r");

l = p.getLine;

while({l.notNil}, {d = d ++ l ++ "\n"; l = p.getLine; });

p.close;

)
Post << d << nl;

d[0..20]

///////////////////////Understanding rrand

a = { |x| sin(x)};
(0..1000).normalize(0, 5pi).collect(a).plot;


a = { |x| sin(x)} rrand: { |x| sin(x) * -1 };
(0..1000).normalize(0, 5pi).collect(a).plot;


(
{a = SinOsc.ar(335); b = SinOsc.ar(MouseX.kr(1, 1000, 1));
rrand(a, b) * 0.1 }.plot;
)
c.play;

rrand(0, 0.1)!5


(
("rand").postln;
~rAND= {1.0.rand}!10;
~rAND.value.postln;


("rrand").postln;
~rRAND= {rrand(0, 1.0)}!10;
~rRAND.value.postln;

0
)
rrand(0, 1.0)


//////////////////////////////// Randomness in SC examples

(

var randomNumbers, histogram, minValue = 5.0, maxValue = 500, numVals = 10000, numBins = 500;


randomNumbers = Array.fill(numVals, { exprand(minValue, maxValue); });

histogram = Signal.newClear(numBins);


randomNumbers.do({ arg each; var count, histoIndex;

	histoIndex = ( each - minValue ).round(1).asInteger;

	count = histogram.at(histoIndex);

	histogram.put(histoIndex, count + 1);

});


histogram.plot("histogram for exprand: " ++ minValue ++ " to " ++ maxValue);

)

(

var randomNumbers, histogram, minValue = 5.0, maxValue = 500, numVals = 100000, numBins = 500;


randomNumbers = Array.fill(numVals, { rrand(minValue, maxValue); });

histogram = Signal.newClear(numBins);


randomNumbers.do({ arg each; var count, histoIndex;

	histoIndex = ( each - minValue ).round(1).asInteger;

	count = histogram.at(histoIndex);

	histogram.put(histoIndex, count + 1);

});


histogram.plot("histogram for rrrand: " ++ minValue ++ " to " ++ maxValue);

)
Ndef(\sound).source
Ndef(\sound, { SinOsc.ar([600, 635], Ndef.ar(\sound), LFNoise1.kr(2).max(0) * 0.2) });
Ndef(\sound).play;
Ndef.clear;

Ndef(\sound).play;
Ndef(\sound).fadeTime = 5;
Ndef(\sound, { SinOsc.ar([600, 635], 0, SinOsc.kr(2).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 3, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 2, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, Pbind(\dur, 0.17, \freq, Pfunc({ rrand(300, 700) })) );

////////////////////////////////// NodeProxy Example

a = NodeProxy.new.play; // play to hardware output.
a.fadeTime = 2; // fadeTime specifies crossfade
// set the source
a.source = { SinOsc.ar([350, 351.3], 0, 0.2)};
a.source = { Pulse.ar([350, 351.3] / 4, 0.4) * 0.2 };
a.source = Pbind(\dur, 0.03, \freq, Pbrown(0, 1, 0.1, inf).linexp(0, 1, 200, 350));

b = NodeProxy.new;
a.source = { Ringz.ar(b.ar, [350, 351.3] * 8, 0.2) * 4 };
b.source = { Impulse.ar([5, 7]/2, [0, 0.5]) };

a.clear(3); // clear after 3 seconds
b.clear(3);


////////////////////////////////// Ndef Example

// define a few chain links
Ndef(\comb, { CombL.ar(\in.ar(0 ! 2), 0.1, LFNoise1.kr(0.1).range(0, 0.1), 2) });
Ndef(\ring, { Ringz.ar(\in1.ar(0 ! 2), LFNoise1.kr(0.1).range(550, 700), 0.2).distort });
Ndef(\filt, { RLPF.ar(\in.ar(0 ! 2), LFNoise1.kr(0.1).range(300, 7000), 0.1) });
Ndef(\dust, { Dust.ar(5 ! 2) });
Ndef(\y, { \in1.ar(0 ! 2) });
// play back one of them
Ndef(\y).play;

Ndef(\dust).unmap
// different combinations
Ndef(\y) <<> nil
Ndef(\ring) <<> nil

Ndef(\my) <<> Ndef(\mring)

Ndef(\ring) <<>.in1 Ndef(\dust);

Ndef(\mring) <<> Ndef(\mcomb);

Ndef(\y) <<>.in1 Ndef(\dust);
Ndef(\y) <<>.in1 Ndef(\ring);
Ndef(\y) <<>.in1 Ndef(\ring) <<> Ndef(\dust);
Ndef(\y) <<> Ndef(\ring) <<> Ndef(\comb) <<> Ndef(\dust);
Ndef(\y) <<> Ndef(\ring) <<> Ndef(\comb) <<> Ndef(\filt) <<> Ndef(\dust);
Ndef(\dust) <>> Ndef(\filt) <>> Ndef(\ring) <>> Ndef(\comb) <>> Ndef(\y);

Ndef(\y) <<> Ndef(\b) <<> Ndef(\x);
Ndef(\y).play;

Ndef(\b, { Ringz.ar(\in.ar(0 ! 2), LFNoise1.kr(0.1).range(550, 700), 0.2).distort });

Ndef(\x, { Dust.ar(5 ! 2) });
//---------------------Other example

s.boot;

Ndef(\sound).play;
Ndef(\sound).fadeTime = 1;
Ndef(\sound, { SinOsc.ar([600, 635], 0, SinOsc.kr(2).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 3, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 2, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, Pbind(\dur, 0.17, \freq, Pfunc({ rrand(300, 700) })) );

Ndef(\lfo, { LFNoise1.kr(3, 400, 800) });
Ndef(\sound).map(\freq, Ndef(\lfo));
Ndef(\sound, { arg freq; SinOsc.ar([600, 635] + freq, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\lfo, { LFNoise1.kr(300, 400, 800) });

Ndef.clear; //clear all Ndefs

//-----HIGH VOLUME!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
(
Ndef(\sound, {
    RHPF.ar(
        \in1.ar([0, 0]) * \in2.ar([0, 0]),
        \freq.kr(6000, 2),
        \rq.kr(0.2)
    ) * 7
}).play;
Ndef(\sound).fadeTime = 0.2;    // avoid harsh clicks
)




Ndef(\a, { SinOsc.ar(MouseX.kr(300, 1000, 1) * [1, 1.2], \phase.ar([0, 0]) * 0.2) });
Ndef(\b, { LFDNoise3.ar(MouseY.kr(3, 1000, 1) * [1, 1.2]) });
Ndef(\c, { LFTri.ar(MouseY.kr(3, 10, 1) * [1, 1.2]).max(0) });
Ndef(\a).fadeTime = 0.2;    // avoid harsh clicks again

Ndef(\sound) <<>.in1 Ndef(\a);
Ndef(\sound) <<>.in2 Ndef(\b);
Ndef(\sound) <<>.in2 Ndef(\c);
Ndef(\a) <<>.phase Ndef(\sound);
Ndef(\a) <<>.phase nil;    // unmap
Ndef.clear(3);        // fade out and clear all Ndefs

// same example as in link::Classes/ProxyPreset:: but using Ndef for Tdef:
(
    // make an empty Tdef
a = Tdef(\a);
    // give it some param settings
a.set(\dt, 0.1, \freq, 440, \bend, 4, \bendVar, 4, \sustain, 0.05);

// add specs for the params to the Tdef - see Halo class.
a.addSpec(\dt, [0.03, 3, \exp]);
a.addSpec(\bend, [-24, 24, \lin]);
a.addSpec(\bendVar, [-24, 24, \lin]);
a.addSpec(\sustain, [0.003, 3, \exp]);

// define what the Tdef does
Tdef(\a, { |env|
    loop({
        (
            instrument: \pingbend,
            freq:  env[\freq],
            bend: env[\bend] + env[\bendVar].rand2,
            sustain: env[\sustain],
            pan: 1.0.rand2
        ).play;

        env[\dt].wait;
    })
});

Tdef(\a).gui;

    // will be using this SynthDef:
s.boot;
SynthDef(\pingbend,
    { arg out=0, freq=440, bend = 4, sustain=0.05;
        var env = EnvGen.ar(Env.perc(0.001, sustain, 0.3), doneAction:2);
        freq = freq * XLine.kr(1, bend.midiratio, sustain);
        Out.ar(out, SinOsc.ar(freq, 0, env))
    }).add;

)

// brain transplant
Ndef(\a, { arg freq=440, bend = 4, sustain=0.05, dt = 0.1;
    var trig = Impulse.ar(1/dt);
    var env = EnvGen.ar(Env.perc(0.001, sustain, 0.3), trig);
    freq = freq * EnvGen.ar(Env([1, bend.midiratio], [sustain], \exp), trig);
    Pan2.ar(SinOsc.ar(freq, 0, env), TRand.ar(-1.0, 1.0, trig));
});

Tdef(\a).envir.keysValuesDo { |k, v| Ndef(\a).set(k, v) };
Ndef(\a).addHalo(\spec, Tdef(\a).getSpec);
Ndef(\a).getSpec === Tdef(\a).getSpec;

Ndef(\a).play;

Ndef(\a).gui;
    // then make a ProxyPreset for for the Tdef:
    // for Tdefs, best use TdefPreset.
b = NdefPreset(Ndef(\a));

// these are the param names for which settings are stored
// they can be reordered, see ParamGui help file.
b.namesToStore;
// in emergencies:
NdefPreset.all.clear;
Ndef(\a).addHalo(\namesToStore, Ndef(\a).controlKeys);
NdefPreset(Ndef(\a));

    // add the current state of the envir as a setting
b.addSet(\ada);

    // make and add 3 random settings
(
b.setRand(0.25); b.addSet(\bobo);
b.setRand(0.25); b.addSet(\coco);
b.someRand(0.25, 0.5); b.addSet(\dad);
)
    //
b.getSetNames;
b.settings.printcsAll;"";

b.setCurr(b.getSetNames.choose.postln);
b.setTarg(b.getSetNames.choose.postln);


// a gui for the NdefPreset
g = NdefPresetGui(b, 8).moveTo(10, 200);

b.morph(1.0.rand, \ada, \coco);

b.xfadeTo(\coco, 3, { "xfade doneFunc done.".postln; });
b.xfadeTo(b.getSetNames.choose.postln, exprand(0.3, 10));

// do recursive crossfading
(
f = {
    "next xfade: ".post;
    b.xfadeTo(b.getSetNames.choose.postln, exprand(0.3, 10), f)
};

f.value;
)
f = nil; // stop

// set relative to a preset:
b.getSetNorm(\coco);
b.proxy.setUni(*(b.getSetNorm(\curr) + [0.1.rand2]).flat);

b.setRelFrom(\coco, { 0.3.rand2 }.dup(b.namesToStore.size))



(
Ndef(\sound, {
    RHPF.ar(
        \in1.ar([0, 0]) * \in2.ar([0, 0]),
        \freq.kr(6000, 2),
        \rq.kr(0.2)
    ) * 7
}).play;
Ndef(\sound).fadeTime = 0.2;    // avoid harsh clicks
)

Ndef(\a, { SinOsc.ar(\test.kr(500) * [1, 1.2], \phase.ar([0, 0]) * 0.2) });
Ndef(\b, { LFDNoise3.ar(MouseY.kr(3, 1000, 1) * [1, 1.2]) });
Ndef(\c, { LFTri.ar(MouseY.kr(3, 10, 1) * [1, 1.2]).max(0) });
Ndef(\a).fadeTime = 0.2;    // avoid harsh clicks again

Ndef(\sound) <<>.in1 Ndef(\a);
Ndef(\sound) <<>.in2 Ndef(\b);
Ndef(\sound) <<>.in2 Ndef(\c);
Ndef(\a) <<>.phase Ndef(\c);
Ndef(\a) <<>.test ~busMouseX;
Ndef(\a).map(\test, ~busMouseX);

Ndef(\a) <<>.test nil;
Ndef(\a) <<>.phase nil;    // unmap
Ndef.clear(3);
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// END /////////////////////////////////////////////
