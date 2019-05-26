(
Server.supernova;
Server.default = s = Server.local;
s.options.sampleRate_(48000);
s.options.numOutputBusChannels = 6;
s.options.numInputBusChannels = 2;


//"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");
"SC_JACK_DEFAULT_OUTPUTS".setenv("Volume_Master:input_1,Volume_Master:input_2,Volume_Master:input_3,Volume_Master:input_4,Volume_Master:input_5,Volume_Master:input_6");


)
(
s.boot;
OpenObject.start;
s.scope;
)

s.recSampleFormat_("int24");
s.quit;
s.makeGui;

//s.prepareForRecord("/Volumes/ALEX_BUCK_2T_USBC/MADRIGALE_A_SEI_VASI/PERFORMANCE/sabado.aif");
//s.record;
//s.stopRecording;
/////////////////////////////////////////////////////////////////////////////////////////////////


//------------------------- Choosing SoundBank folder

~folder = "../Sons/ESTRUTURAS/VOZ_LUANA/";
~folder = "../Sons/MADRIGAL_materiais";
//~folder = "../Sons/Vasos_Camila/";



//------------------------- Building an Array with the sound paths

(var paths, soundPath;

~paths = List[];

//paths = Pipe.new("ls ../Sons/Vozes_Luana_BRC_Estudios/", "r");
paths = Pipe.new("ls " + ~folder, "r");


soundPath = paths.getLine;

while({soundPath.notNil}, {

		~paths = ~paths.add(soundPath);
		soundPath = paths.getLine;

});

paths.close;




~paths;
)

//v={PanAz.ar(6, PlayBuf.ar(1, \bufnum.kr(0), trigger: Impulse.kr(\trigg.kr(0.05))), pos: \position.kr(-1), orientation: \orientatio.kr(-3.0) );}

//z={arg buf; PanAz.ar(6, PlayBuf.ar(1, buf.bufnum, trigger: Impulse.kr(\trigg.kr(0.05))), pos: \position.kr(-1), orientation: \orientatio.kr(-3.0) );}


//w={|bufnum=0, trigg=0.05, position= -1, orientatio= -3.0| PanAz.ar(6, PlayBuf.ar(1, bufnum, trigger: Impulse.kr(trigg)), pos: position, orientation: orientatio );}



/////////////////////////////////////////////////////////////////////////////////////////////////


//-------------------------- Buffer NDefs

//(

//r=Ndef(\playbuf6, {

	//PanAz.ar(6, PlayBuf.ar(1, \bufnum.kr(0), trigger: \trigg.ar(1)), pos: \position.kr(-1), orientation: \orientatio.kr(-3.0) );
//});

//)

//-------------------------- Control Ndefs

(

~modulatorNdef = Ndef(\modulator, {
	SinOsc.kr(\freq.kr(1)).range(-2,2);
}).add;

~mouseXNdef = Ndef(\control_mouseXs1, { |lim=1|
	MouseX.kr(-1*lim, lim);
}).add;

)


/////////////////////////////////////////////////////////////////////////////////////////////////

//NDEF VERSION



(
~pbuf6 = Ndef(\playbuf6);
~pbuf6.fadeTime = 3;
~pbuf6.addSpec(\position, [-1, 1, \lin]);
~pbuf6.addSpec(\bufnum, [0, 1, \lin]);
NdefPreset.new(Ndef(\playbuf6), [\bufnum, \position]);
~pbuf6Preset = NdefPreset(Ndef(\playbuf6));
~pbuf6Preset.addSet(\cucu, [[\bufnum, 0], [\position, -1]]);
~pbuf6Preset.addSet(\coco, [[\bufnum, 0], [\position, -0.5]]);
)

~pbuf6.play

//--- printing options

~pbuf6Preset.settings.printcsAll;"";
~pbuf6Preset.getSetNames;
~pbuf6Preset.getCurr;
~pbuf6Preset.settingsString;
~pbuf6Preset.checkSpecsMissing;
~pbuf6Preset.namesToStore;


NdefPreset.all
NdefPreset.all.clear

//-------------------------- Start/Reset a NodeProxy source and read a new buffer

[\fj, \tre, \hdt][0]

(

~pbuf6 = Ndef(\playbuf6, {

	PanAz.ar(6, PlayBuf.ar(1, bufnum: \bufnum.kr(11), trigger: \trigg.ar(1)), pos: \position.kr(-1), orientation: \orientatio.kr(-3.0) );
});

)
NdefMixer
Mix
MixedBundle
(
m = {
	arg buf;
	buf.close;
	buf.postln;

	~pbuf6 = Ndef(\playbuf6, {

		Array.fill(1, PanAz.ar(6, PlayBuf.ar(1, buf.bufnum, trigger: \trigg.ar(1)), pos: \position.kr(-1), orientation: \orientatio.kr(-3.0) )).reshape(6);
	});



};
)
(

var len;
len = ~paths.size;

~kbufLoad = {~kbuf = Buffer.read(s, ~folder +/+ ~paths.wchoose(1/len !len ), startFrame: rand(10000000).postln, numFrames: 800000, action: m, bufnum: 45);};
~kbufLoad2 = {~kbuf2 = Buffer.read(s, ~folder +/+ ~paths.wchoose(1/len !len ), startFrame: rand(10000000).postln, numFrames: 800000, action: m, bufnum: 46);};


)
[1,2].choose

(
j.stop;
j = {var len;
	len = ~paths.size;
	inf.do{

		~modulatorNdef.set(\freq, [ linrand(-0.5) + 0.5, rand(1000) + 200].choose.postln);


	~kbufLoad.fork;
	0.1.wait;
	(~kbuf.duration/2).wait;


		~modulatorNdef.set(\freq, [ linrand(-0.5) + 0.5, rand(1000) + 200].choose.postln);


	~kbufLoad2.fork;
	0.1.wait;
	(~kbuf.duration/1.3).wait;
	}
}.fork

)

j.play;
j.reset;
j.stop;
Routine
Buffer
~kbuf.free
Ndef.ar(\playbuf6, 6)
~pbuf6.reshaping = \elastic;
~kbuf.numFrames
~kbuf.duration.postln

~kbuf
~test
~kbuf = {Buffer.read(s, ~folder +/+ ~paths.wchoose(1/2 !2 ), numFrames: 800000, action: m, bufnum: 45);};

~test = {~kbuf = Buffer.read(s, ~folder +/+ ~paths.wchoose(1/2 !2 ), numFrames: 800000, action: m, bufnum: 45);}
~test.fork

//--------------------------- Controlling parameters

~pbuf6.controlKeys;
rand(10.0)
~as = \asd

Ndef(~as)
~kbuf.bufnum

//--- sets and static controls

~pbuf6.set(\bufnum, 1);
~pbuf6.set(\position, -1)
~pbuf6.set(\bufnum, 10)

~pbuf6.set(\orientatio, -3)

//---- With NdefPreset

~pbuf6Preset.xfadeTo(\coco, 3);
~pbuf6Preset.xfadeTo(\cucu, 3);

~pbuf6Preset.setCurr(\coco);
~pbuf6Preset.setCurr(\cucu);

~pbuf6Preset.morph(0.5, \coco, \cucu);

//--- UGen control with Ndef mapping <<> operator


// <<> operator resets the opperator

~pbuf6 <<>.position nil;
~pbuf6 <<>.position ~modutalorNdef;


~pbuf6 <<>.position nil;
~pbuf6 <<>.position ~mouseXNdef;

~pbuf6 <<>.orientatio nil;
~pbuf6 <<>.orientatio ~mouseXNdef;

~pbuf6 <<>.bufnum ~kbuf.bufnum;
~pbuf6 <<>.bufnum nil
~pbuf6 <<>.bufnum ~kbuf.bufnum -2;
// map does not reset the operator

~pbuf6.map(\orientatio, ~mouseXNdef);
~pbuf6.map(\orientatio, nil);

~pbuf6.map(\position, ~mouseXNdef);
~pbuf6.map(\position, ~modulatorNdef);
~pbuf6.map(\position, nil);

~mouseXNdef.set(\lim, 3)
~modulatorNdef.set(\freq, 1.2)

n = NodeProxy.new;
n.play;
n.fadeTime = 1;
r = Ndef(\playbuf6)
n.source = v;
n.source = Ndef(\playbuf6, v)
n.source = {Impulse.ar(1)}
v.set([\bufnum, 2])


Ndef(\playbuf6).set(\bufnum, 1.1)




x.set([\orientatio, 2.01])
w.set([\bufnum, 1])



r = Ndef(\playbuf6)
r.play


//--------------------------- Objects analysis


s.scope
s.queryAllNodes;

x;
x.trace;

k;


Ndef(\sound).play;


(
var a, b, c, t;
a = Pbind(\x, Pseq([1, 2, 3, 4]), \dur, 1);
b = Pbind(\x, Pseq([10, 20, 30, 40]), \dur, 0.4);
c = Ppar([a, b]);
t = c.asStream;
20.do({ t.next(Event.default).postln; });
)
(
var a, b;
a = Pbind(\note, Pseq([7, 4, 0], 4), \dur, Pseq([1, 0.5, 1.5], inf));
b = Pbind(\note, Pseq([5, 10, 12], 4), \dur, 1);
Ppar([ a, b ]).play;
)



/////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// END /////////////////////////////////////////////
