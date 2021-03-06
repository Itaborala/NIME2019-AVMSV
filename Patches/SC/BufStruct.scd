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
s.scope

s.recSampleFormat_("int24");
s.quit;
s.makeGui;

//s.prepareForRecord("/Volumes/ALEX_BUCK_2T_USBC/MADRIGALE_A_SEI_VASI/PERFORMANCE/sabado.aif");
//s.record;
//s.stopRecording;
/////////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------Testes Iniciais

{PanAz.ar(6, WhiteNoise.ar(0.1) , pos: MouseX.kr(-1, 1), orientation: -3.0)}.play

{Array.fill(1, PanAz.ar(3, {WhiteNoise.ar(0.1)}!2 , pos: MouseX.kr(-1, 1), orientation: -1.5)).reshape(6)}.play

{Array.fill(1, PanAz.ar(1, {WhiteNoise.ar(0.1)}!6 , pos: MouseX.kr(-1, 1), orientation: -1.5)).reshape(6)}.play


//------------------------- Choosing SoundBank folder

//~folder = "../Sons/ESTRUTURAS/VOZ_LUANA/";
//~folder = "../Sons/MADRIGAL_materiais";
//~folder = "../Sons/Vasos_Camila/";
~folder = "../Sons";


//------------------------- Building a Dictionary with the sound paths


(
~pathsDict = Dictionary.new;
PathName(~folder).entries.do{
	arg subfolder;
	~pathsDict.add(
		subfolder.folderName.asSymbol ->
		Array.fill(
			subfolder.entries.size,
			{
				arg i;
				subfolder.entries[i].fullPath;
			}
		)
	);
};

~len = {|key| ~pathsDict[key].size};

~pathsDict
)


/////////////////////////////////////////////////////////////////////////////////////////////////

//NDEF VERSION
//-------------------------- Buffer NDefs and Presets

(
Ndef.new(\playbuf6).ar(6);
~pbuf6 = Ndef(\playbuf6);
~pbuf6FadeTime = 3;
~pbuf6.fadeTime = ~pbuf6FadeTime;
~pbuf6.addSpec(\position, [-1, 1, \lin]);
~pbuf6.addSpec(\bufnum, [0, 1, \lin]);
NdefPreset.new(Ndef(\playbuf6), [\bufnum, \position]);
~pbuf6Preset = NdefPreset(Ndef(\playbuf6));
~pbuf6Preset.addSet(\cucu, [[\bufnum, 0], [\position, -1]]);
~pbuf6Preset.addSet(\coco, [[\bufnum, 0], [\position, -0.5]]);
)

~pbuf6.play
~pbuf6_2 = ~pbuf6.copy(\pbuf6_2)

//--- printing options

~pbuf6Preset.settings.printcsAll;"";
~pbuf6Preset.getSetNames;
~pbuf6Preset.getCurr;
~pbuf6Preset.settingsString;
~pbuf6Preset.checkSpecsMissing;
~pbuf6Preset.namesToStore;

Ndef.all
Ndef.all.clear

NdefPreset.all
NdefPreset.all.clear


//-------------------------- Control Ndefs

(
~modulatorNdef = Ndef(\modulator, {
	SinOsc.kr(\freq.kr(0.02)).range(-6, 6);
}).add;

~mouseXNdef = Ndef(\control_mouseXs1, { |lim=1|
	MouseX.kr(-1*lim, lim);
}).add;

~mouseYNdef = Ndef(\control_mouseYs1, { |lim=1|
	MouseY.kr(-1*lim, lim);
}).add;
~lfnoiseNdef = Ndef(\control_lfnoises1, { |freq=1|
	LFNoise2.kr(freq);
}).add;


)
(
~ctrl_pos = Ndef(\control_pos, ~modulatorNdef.source);

)



/////////////////////////////////////////////////////////////////////////////////////////////////

//-------------------------- Start/Reset a NodeProxy source and read a new buffer

~pbuf6.sources

(
~pbuf6.put(0,
	{

		var sig;

		sig = PlayBuf.ar(1, \bufn.kr(0));

		sig = PanAz.ar(6,
			in: sig,
			pos: \pos.kr(-1),
			level: \amp.kr(1.0),
			orientation: \orientation.kr(-3.0)
		);

		//Reshaping

		Array.fill(1, sig).reshape(6);
	},

	now: false
);
)
Line
//////////
////////////////////////////////////////////////
~pbuf6.send([\bufn, 2], 1)
////////////////////////////////////////////////
/////////

(
c = {
	arg buf;
	buf.close;

	("reading buffer:" + buf).postln;
	~pbufTdef

};
)

~folderKey = \Ceramicas_Amanda;
//~folderKey = \Vozes_Mistro;
//len = ~len.value(folderKey);
~kbuf
~kbuf = Array.fill(16)
(
~kbufRead = {
	arg bufn = 15, key = \Vozes_Mistro;

	var len = ~len.value(key);

	~kbuf[bufn] = Buffer.read(s,
		path: ~pathsDict[key].wchoose(1/len !len ),
		startFrame: rand(10000),
		numFrames: 600000,
		action: c,
		bufnum: bufn;
	);

	"reading buffer....";
};
)
~kbufRead.value(2, \Ceramicas_Amanda)
~kbuf[2].duration

//----Routine
~pbuf6.play

(
~pbufTdef = Tdef(\l,
	{
		~pbuf6.play;
		~pbuf6.map(\pos, nil);
		~pbuf6.map(\pos, ~ctrl_pos);


		loop {


			~pbuf6.send([\bufn, 2], 0);
			("playing buffer ---- 2 ----" + PathName(~kbuf[2].path).fileName).postln;
			~kbufRead.value(3, key: ~folderKey);
			(~kbuf[2].duration - ~pbuf6FadeTime/2).wait;

			~pbuf6.send([\bufn, 3], 0);
			("playing buffer ---- 3 ----" + PathName(~kbuf[3].path).fileName).postln;
			~kbufRead.value(1, key: ~folderKey);
			(~kbuf[3].duration - ~pbuf6FadeTime/2).wait;

			~pbuf6.send([\bufn, 1], 0);
			("playing buffer ---- 1 ----" + PathName(~kbuf[1].path).fileName).postln;
			~kbufRead.value(2, key: ~folderKey);
			(~kbuf[1].duration - ~pbuf6FadeTime/2).wait;



		}.fork;


	};

);
)
(~kbuf.duration - ~pbuf6FadeTime/2.1)
~pbufTdef.play;
~pbufTdef.stop;
~pbufTdef.reset;
~pbufTdef.next;

~pbuf6[0].play
~ctrl_pos
~ctrl_pos.source = ~modulatorNdef;
~ctrl_pos.source = ~mouseXNdef.source;
~ctrl_pos.source = ~lfnoiseNdef.source;

j.play;
j.reset;
j.stop;
~pbuf6.source.do(_.postcs);
PathName("../Sons/Ceramicas_Amanda/Vassoura_Urna-G_KM-164_04.wav").folderName
//--------------------------- Controlling parameters

~pbuf6.controlKeys;
rand(10.0)
~as = \asd

Ndef(~as)
~kbuf.bufnum

//--- sets and static controls

~pbuf6.set(\bufnum, 1);
~pbuf6.set(\pos, 0)
~pbuf6.set(\bufnum, 10)

~pbuf6.set(\orientatio, -3)
~kbufLoad.fork
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


~pbuf6 <<>.pos nil;
~pbuf6 <<>.position ~mouseXNdef;

~pbuf6 <<>.orientatio nil;
~pbuf6 <<>.orientatio ~mouseXNdef;

~pbuf6 <<>.bufnum ~kbuf.bufnum;
~pbuf6 <<>.bufnum nil
~pbuf6 <<>.bufnum ~kbuf.bufnum -2;
// map does not reset the operator

~pbuf6.map(\orientatio, ~mouseXNdef);
~pbuf6.map(\orientatio, nil);

~pbuf6.map(\pos, ~mouseXNdef);
~pbuf6.map(\pos, ~modulatorNdef);
~pbuf6.map(\pos, ~ctrl_pos);


~mouseXNdef.set(\lim, 3)
~modulatorNdef.set(\freq, 0.006)

~pbuf6.nodeID
~pbuf6.group
~pbuf6.trace

Ndef.nodeID
Ndef.dictFor(s);

//--------------------------- Objects analysis

s.scope
s.queryAllNodes;







/////////////////////////////////////////////////////////////////////////////////////////////////



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




Ndef(\maus, { MouseX.kr });
Ndef(\haus, { Blip.ar(Ndef.kr(\maus) * 70) }).play;
Ndef(\haus).reshaping = \elastic;
Ndef(\maus).reshaping = \elastic;
Ndef(\maus, { LFNoise0.kr(1 ! 8) + 1 }); // now 8 parallel channels of audio are audible.

Cepstrum

// put can be used with the array indexing syntax:
a = NodeProxy.new.play;
a[0] = { SinOsc.ar(Rand(200, 899)) * 0.1.dup };
a[2] = { SinOsc.ar(Rand(200, 899)) * 0.1.dup };
a.sources.do(_.postcs);
// using multiple index expands into multiple objects
a[0..5] = { SinOsc.ar(Rand(200, 899)) * 0.1.dup };
a.sources.do(_.postcs);
a.send; // exchange synths, using the sources as definitions
a.clear;

/////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// END /////////////////////////////////////////////
