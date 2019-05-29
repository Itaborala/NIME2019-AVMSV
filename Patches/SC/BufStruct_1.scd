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
//--- rate de leitura, sons muito concretos, tocar os mesmos buffers com novos processamentos
//--------------------------------- Testes Iniciais

x = {PanAz.ar(6, WhiteNoise.ar(0.05) , pos: MouseX.kr(-1, 1), orientation: -3.0)}.play
x.free
{Array.fill(1, PanAz.ar(3, {WhiteNoise.ar(0.1)}!2 , pos: MouseX.kr(-1, 1), orientation: -1.5)).reshape(6)}.play

{Array.fill(1, PanAz.ar(1, {WhiteNoise.ar(0.1)}!6 , pos: MouseX.kr(-1, 1), orientation: -1.5)).reshape(6)}.play


//--------------------------------- Choosing SoundBank folder

//~folder = "../Sons/ESTRUTURAS/VOZ_LUANA/";
//~folder = "../Sons/MADRIGAL_materiais";
//~folder = "../Sons/Vasos_Camila/";
~folder = "../Sons";


//--------------------------------- Building a Dictionary with the sound paths


(
~folder = "../Sons";
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

//---------------------------------- Declaring Global Variables and Functions
(
//--- Tracks all instances of a node group
//--- that are not being used

~pbuf6AvailableNodes = SortedList.new(8, function: {|a, b| a > b});
30.do{arg i; ~pbuf6AvailableNodes.add(i); ~pbuf6AvailableNodes};
~pbuf6AvailableNodes;
//~pbuf6AvailableNodes.clear

~availableNodesReset = {~pbuf6AvailableNodes.clear; 30.do{arg i; ~pbuf6AvailableNodes.add(i)};};

//--- Helps breaking the task loop properly
~stop = Array.fill(30, Condition(false));
~stop;

//--- Holds the subfolder keys that
//--- will be read by each group respectively
~folderKey = Array.fill(30, \Silence);
~folderKey;

//--- Stores All Buffers
//~kbuf = Array.fill(90, {|i| Buffer.new(s, numFrames: 40000, numChannels: 1, bufnum: i)});
~kbuf = Array.fill(90);

//--- Stores Tdefs forks plus one to avoid overload
~st1 = Array.fill(100);


)
/////////////////////////////////////////////////////////////////////////////////////////////////
~st1 = Array.fill(100);
~folderKey = Array.fill(10, \Ceramicas_Amanda);
//---------------------------------- Main Ndef

//--- Declaring \playbuf6

(
Ndef.new(\playbuf6).ar(6);
~pbuf6 = Ndef(\playbuf6);
~pbuf6FadeTime = 0.7;
)

//--- Declaring NodeProxy sources at all instances
(
~pbuf6instances = 30.do{ arg i;
~pbuf6.put(i,
	{

		var sig;

		sig = PlayBuf.ar(1, \bufn.kr(0), rate: \rate.kr(1.0), doneAction:0);//rand(0.3) + 7.5,

		sig = PanAz.ar(6,
			in: sig,
			pos: LFNoise2.kr(1),
			level: \amp.kr(1.0),
			orientation: \orientation.kr(-3.0)
		);

		//Reshaping

		Array.fill(1, sig).reshape(6);
	},

	now: false
);
}
)
~pbuf6.sources

/////////////////////////////////////////////////////////////////////////////////////////////////


//---------------------------------- Control Ndefs

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


//---------------------------------- NDefPresets

//--- Presets for \playbuf6
(
~pbuf6.fadeTime = ~pbuf6FadeTime;
)
(
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

Ndef.all
Ndef.all.clear

NdefPreset.all
NdefPreset.all.clear

/////////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------- Buffer Read Function

//-- Completion action
(
c = {
	arg buf;
	buf.close;

	//("reading buffer:" + buf).postln;
	//~pbufTdef

};
)




(
~kbufRead = {
	arg bufn = 0, key = \Silence, frames= -1;

	var len = ~len.value(key);

	~kbuf[bufn] = Buffer.read(s,
		path: ~pathsDict[key].wchoose(1/len !len ),
		startFrame: rand(1000),
		numFrames: frames,
		action: c,
		bufnum: bufn;
	);

	"reading buffer....";
};
)

//-- You need to initialize all the available
//-- buffers before forking routines and tasks

90.do{|i| ~kbufRead.value(i)};
~kbuf

/////////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------- Buffer Structure source

~kbuf[0].duration
(
~pbufTdef = Tdef(\BufStruct,
	{

		|args|
		var nodeIndex;
		//args[\yay].postln;

		//~pbuf6.map(\pos, nil);
		//~pbuf6.map(\pos, ~ctrl_pos);

		nodeIndex = ~pbuf6AvailableNodes.pop;

		if(nodeIndex == nil,
			{ ("All group instances taken!!").postln},

			{
				~pbuf6.play;
				("Task Running at node group " + ~pbuf6.nodeID + " instance " + nodeIndex).postln;
				~stop[nodeIndex].test = false;

				block {|break|

					inf.do{


						~pbuf6.send([
							\bufn, 3*nodeIndex +0,
							\rate, case
							{args[\vel] == "static1"} {1}
							{args[\vel] == "static7.5"} {7.5}
							{args[\vel] == "RandL"} {rand(0.17) + 0.03}
							{args[\vel] == "RandM"} {rand(0.3) + 0.85}
							{args[\vel] == "RandH"} {rand(0.9) + 1.1}
							{args[\vel] == "RandHH"} {rand(2) + 2}
							{args[\vel] == "RandB"} {rand(1.95) + 0.05};,

							\amp, case
							{args[\mul] == "static1"} {1}
							{args[\mul] == "Rand"} {rand(0.5) + 0.5};


						], nodeIndex);


						("playing buffer ----"+
							~kbuf[3*nodeIndex +0].bufnum +"----"+
							~kbuf[3*nodeIndex +2].duration + "s " +
							PathName(~kbuf[3*nodeIndex +0].path).fileName).postln;

						~kbufRead.value(3*nodeIndex +1,
							key: ~folderKey[nodeIndex],
							frames: case
							{args[\frames] == "wchoose8m1"} {[400000, -1].wchoose([9/10, 1/10])}
							{args[\frames] == "full"} {-1};


						);

						w = case
						{args[\waiting] == "bufdur"} {(~kbuf[3*nodeIndex +0].duration - ~pbuf6FadeTime/2)}
						{args[\waiting] == "rand"} {(rand(2.5) + 4.2)};

						w.wait;

						if(~stop[nodeIndex].test == true) { break.value(999) };

						//("Working" + [1, 2].wchoose([args[\wch], 1 - args[\wch]])).postln;


						~pbuf6.send([
							\bufn, 3*nodeIndex +1,
							\rate, case
							{args[\vel] == "static1"} {1}
							{args[\vel] == "static7.5"} {7.5}
							{args[\vel] == "RandL"} {rand(0.17) + 0.03}
							{args[\vel] == "RandM"} {rand(0.3) + 0.85}
							{args[\vel] == "RandH"} {rand(0.9) + 1.1}
							{args[\vel] == "RandHH"} {rand(2) + 2}
							{args[\vel] == "RandB"} {rand(1.95) + 0.05};,

							\amp, case
							{args[\mul] == "static1"} {1}
							{args[\mul] == "Rand"} {rand(0.5) + 0.5};


						], nodeIndex);

						("playing buffer ----"+
							~kbuf[3*nodeIndex +1].bufnum +"----"+
							~kbuf[3*nodeIndex +1].duration + "s " +
							PathName(~kbuf[3*nodeIndex +1].path).fileName).postln;

						~kbufRead.value(3*nodeIndex +2,
							key: ~folderKey[nodeIndex],
							frames: case
							{args[\frames] == "wchoose8m1"} {[400000, -1].wchoose([9/10, 1/10])}
							{args[\frames] == "full"} {-1};

						);

						w = case
						{args[\waiting] == "bufdur"} {(~kbuf[3*nodeIndex +1].duration - ~pbuf6FadeTime/2)}
						{args[\waiting] == "rand"} {(rand(2.5) + 4.2)};

						w.wait;


						if(~stop[nodeIndex].test == true) { break.value(999) };


						~pbuf6.send([
							\bufn, 3*nodeIndex +2,
							\rate, case
							{args[\vel] == "static1"} {1}
							{args[\vel] == "static7.5"} {7.5}
							{args[\vel] == "RandL"} {rand(0.17) + 0.03}
							{args[\vel] == "RandM"} {rand(0.3) + 0.85}
							{args[\vel] == "RandH"} {rand(0.9) + 1.1}
							{args[\vel] == "RandHH"} {rand(2) + 0.9}
							{args[\vel] == "RandB"} {rand(1.95) + 0.05};,

							\amp, case
							{args[\mul] == "static1"} {1}
							{args[\mul] == "Rand"} {rand(0.5) + 0.5};


						], nodeIndex);
						("playing buffer ----"+
							~kbuf[3*nodeIndex +2].bufnum +"----"+
							~kbuf[3*nodeIndex +2].duration + "s " +
							PathName(~kbuf[3*nodeIndex +2].path).fileName).postln;

						~kbufRead.value(3*nodeIndex + 0,
							key: ~folderKey[nodeIndex],
							frames: case
							{args[\frames] == "wchoose8m1"} {[400000, -1].wchoose([9/10, 1/10])}
							{args[\frames] == "full"} {-1};

						);


						w = case
						{args[\waiting] == "bufdur"} {(~kbuf[3*nodeIndex +2].duration - ~pbuf6FadeTime/2)}
						{args[\waiting] == "rand"} {(rand(2.5) + 4.2)};

						w.wait;


						if(~stop[nodeIndex].test == true) { break.value(999) };

					};
				};
				~pbuf6AvailableNodes.add(nodeIndex);
				("Ending Task at node group " + ~pbuf6.nodeID + " instance " + nodeIndex).postln;
			}
		);


	};

);

~pbufTdef1 = ~pbufTdef.copy(\BufStruct1);
~pbufTdef2 = ~pbufTdef.copy(\BufStruct2);

)



(
~keysTdef = Tdef(\choosekeys,
	{|args|
		loop {
			30.do{|i|
				~folderKey[i] = [args[\fkey1], args[\fkey2]].wchoose([args[\fkeych], 1-args[\fkeych]]);

				//("Folder " + i + " was now set to " + ~folderKey[i]).postln;

			};


			"Folder keys are now set to: ".postln;
			(~folderKey[0..4]).postln;
			(~folderKey[5..9]).postln;
			(~folderKey[10..14]).postln;
			(~folderKey[15..19]).postln;
			(~folderKey[20..24]).postln;
			(~folderKey[25..29]).postln;
			4.wait
		};
	};

);
~keysTdef.publish(\chooseKey);
)


/////////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------- Routines for 1st BufferStruct

// \frames Control Options: 0 ==>

//---------------------------------- Routine 1

//-- Play randomly all 10 instances
(
{
	~pbufTdef1.set(\frames, "wchoose8m1", \waiting, "bufdur", \vel, "static1", \mul, "static1");


	//~folderKey[1] = \Vozes_Mistro;
	//~folderKey[2] = \Tratados;
	//~folderKey[6] = \VOZ_LUANA;
	//~folderKey[7] = \MADRIGAL_materiais;
	//~folderKey[3] = \Silence;

	10.do{~pbufTdef1.fork; 2.0.wait;};

}.fork;
)
//-- Stop Routine 1
(
10.do{|i| ~stop[i].test = true};
)

//-- Reset available nodes if necessary
~pbuf6AvailableNodes;
~availableNodesReset.value;

//-- Check Main NDef sources
~pbuf6.source.do(_.postcs);

//---------------------------------- Routine 2

(
{
	90.do{|i| ~kbufRead.value(i)};
	1.wait;
	30.do{|i| ~folderKey[i] = \Silence;};

	~pbufTdef2.set(\frames, "full", \waiting, "rand", \vel, "static1", \mul, "Rand");
	30.do{~pbufTdef2.fork; 0.4.wait;};

	~keysTdef.set(\fkey1, \Silence, \fkey2, \Attack_Short, \fkeych, 1);
	~choosekeys = ~keysTdef.fork;


}.fork;
)

~pbufTdef2.set(\vel, "RandH")
~keysTdef.set(\fkey1, \Attack_Long);
~keysTdef.set(\fkey1, \Silence);



~kbufRead.value(0, \Short)

~pbuf6.send([\bufn, 0], 0)


//-- Stop Routine 2

(
30.do{|i| ~stop[i].test = true};
~choosekeys.stop;
)
~pbuf6AvailableNodes;
~availableNodesReset.value;

~testTdef =  Tdef(\kl, {|args| loop{[1, 2].wchoose([args[\de], 1 - args[\de]]).postln; 1.0.wait}})

~df = ~testTdef.fork
~df.stop

~testTdef.stop

~testTdef.set(\de, 3);

~testTdef.publish(\testee)
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
(
~pbufTdef1.stop;
~availableNodesReset.value;
~pbuf6AvailableNodes
)
~pbufTdef1.gui



~ctrl_pos
~ctrl_pos.source = ~modulatorNdef;
~ctrl_pos.source = ~mouseXNdef.source;
~ctrl_pos.source = ~lfnoiseNdef.source;



PathName("../Sons/Ceramicas_Amanda/Vassoura_Urna-G_KM-164_04.wav").folderName
//--------------------------- Controlling parameters
~pbufTdef1.controlKeys
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


Array.fill(10, {{MouseX.kr.poll(2)}.play})

l={ Poll.kr(Impulse.kr(10), Line.kr(0, 1, 1), \test) }.play(s);
l.stop
a = {MouseX.kr}.defer
a.value

[1, 2].wchoose([a, 1-a])

Bus


r = Tdef(\r, {|args| {0.2*SinOsc.ar(freq: args[\f])}.play})

v = Ndef(\v, {MouseX.kr(300, 500)});


r.set(\f, 540)
r.play



NodeProxy

~pbufTdef2.fork;

~pathsDict[\Silence]

///////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// END /////////////////////////////////////////////
