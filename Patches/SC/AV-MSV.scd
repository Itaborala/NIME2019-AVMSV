(
Server.supernova;
Server.default = s = Server.local;
s.options.sampleRate_(48000);
s.options.numOutputBusChannels = 6;
s.options.numInputBusChannels = 2;


//"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");
"SC_JACK_DEFAULT_OUTPUTS".setenv("Volume_Master:input_1,Volume_Master:input_2,Volume_Master:input_3,Volume_Master:input_4,Volume_Master:input_5,Volume_Master:input_6");
//"SC_JACK_DEFAULT_OUTPUTS".setenv("Headphones:playback_1,Headphones:playback_1,Headphones:playback_1,Headphones:playback_2,Headphones:playback_2,Headphones:playback_2,");


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
	SinOsc.kr(\freq.kr(1)).range(-2,2);
}).add;

~mouseXNdef = Ndef(\control_mouseXs1, { |lim=1|
	MouseX.kr(-1*lim, lim);
}).add;



~ctrl_pos = Ndef(\control_pos, ~modulatorNdef.source);

)



/////////////////////////////////////////////////////////////////////////////////////////////////


NdefMixer
Mix
MixedBundle
Done
//-------------------------- Start/Reset a NodeProxy source and read a new buffer

~pbuf6.sources

(
~pbuf6[1] = {
		var sig;

		sig = PlayBuf.ar(1, \bufn.kr(47), doneAction: 2);

		sig = PanAz.ar(6,
			in: sig,
			pos: \pos.kr(-1),
			level: \amp.kr(1.0),
			orientation: \orientation.kr(-3.0)
		);

		//Reshaping

		Array.fill(1, sig).reshape(6);
	}


)
~kbufLoad3.fork
(
m = {
	arg buf;
	buf.close;
	buf.postln;

	~pbuf6[0] = {var sig;

		sig = PlayBuf.ar(1, \bufn.kr(buf.bufnum), doneAction: 2);

		sig = PanAz.ar(6,
			in: sig,
			pos: \pos.kr(-1),
			level: \amp.kr(1.0),
			orientation: \orientation.kr(-3.0)
		);

		//Reshaping

		Array.fill(1, sig).reshape(6);
		}

};
)
//////////
////////////////////////////////////////////////
~pbuf6.send([\bufn, 45], 0)
////////////////////////////////////////////////
/////////
(
n = {
	arg buf, ind;
	buf.close;
	buf.postln;

	~pbuf6[1] = {var sig;

		sig = PlayBuf.ar(1, \bufn.kr(buf.bufnum), doneAction: 2);

		sig = PanAz.ar(6,
			in: sig,
			pos: \pos.kr(-1),
			level: \amp.kr(1.0),
			orientation: \orientation.kr(-3.0)
		);

		//Reshaping

		Array.fill(1, sig).reshape(6);
		}

};
)

(
var folderKey, len;

//folderKey = \Ceramicas_Amanda;
folderKey = \Vozes_Mistro;
len = ~len.value(folderKey);

~kbufLoad = {

	~kbuf = Buffer.read(s,
		path: ~pathsDict[folderKey].wchoose(1/len !len ),
		startFrame: rand(100000).postln,
		numFrames: 800000,
		action: m,
		bufnum: 45;
	)
};

~kbufLoad2 = {

	~kbuf2 = Buffer.read(s,
		path: ~pathsDict[folderKey].wchoose(1/len !len ),
		startFrame: rand(100000).postln,
		numFrames: 800000,
		action: m,
		bufnum: 46;
	)
};

~kbufLoad3 = {

	~kbuf3 = Buffer.read(s,
		path: ~pathsDict[folderKey].wchoose(1/len !len ),
		startFrame: rand(100000).postln,
		numFrames: 800000,
		action: n,
		bufnum: 47;
	)
};

)

//----Routines

~kbufLoad2.fork
~len.value(\Vozes_Mistro);
~pathsDict[\Vozes_Mistro]

~pbuf6[0].send


(
~pbufTdef = Tdef(\l,
	{
		~pbuf6.play;
		~pbuf6.map(\pos, nil);
		~pbuf6.map(\pos, ~ctrl_pos);


		loop {

			~modulatorNdef.set(
				\freq, [ linrand(-0.5) + 0.5, rand(1000) + 200].choose.postln);


			~kbufLoad.fork;

			0.1.wait; (~kbuf.duration - ~pbuf6FadeTime/2.1).wait;

			~modulatorNdef.set(
				\freq, [ linrand(-0.5) + 0.5, rand(1000) + 200].choose.postln);


			~kbufLoad2.fork;

			0.1.wait; (~kbuf2.duration - ~pbuf6FadeTime/2.1).wait;

		};


	};

);
)

~pbufTdef.play;
~pbufTdef.stop;

~pbuf6[0].play
~ctrl_pos
~ctrl_pos.source = ~modulatorNdef;
~ctrl_pos.source = ~mouseXNdef;

j.play;
j.reset;
j.stop;
~pbuf6.source.do(_.postcs);

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
~pbuf6.map(\pos, nil);

~mouseXNdef.set(\lim, 3)
~modulatorNdef.set(\freq, 1.2)

~pbuf6.group

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
