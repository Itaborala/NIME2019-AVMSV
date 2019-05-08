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


//------------------------- Choosing SoundBank folder

~folder = "../Sons/ESTRUTURAS/VOZ_LUANA/";
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

/////////////////////////////////////////////////////////////////////////////////////////////////


//-------------------------- Buffer SynthDefs

(

SynthDef(\playbuf6, {

	Out.ar(\out.kr(0), PanAz.ar(6, PlayBuf.ar(1, \bufnum.kr(0)), pos: \position.kr(-1), orientation: \orientatio.kr(-3.0) ));
}).add;

)

//-------------------------- Control Synthdefs

(

SynthDef(\modulator, {
	Out.kr(\out.kr(0), SinOsc.kr(\freq.kr(1)).range(-3,3));
}).add;

SynthDef(\control_mouseXs1, {
	Out.kr(\out.kr(0), MouseX.kr(-1, 1));
}).add;

)


/////////////////////////////////////////////////////////////////////////////////////////////////

//SYNTHDEF VERSION


//-------------------------- Start a Synth function

(

var len;
len = ~paths.size;

m = { arg buf; buf.close; x = Synth.new(\playbuf6, [\bufnum, buf.bufnum])};

k = Buffer.read(s, ~folder +/+ ~paths.wchoose(1/len !len ), action: m);

)

//--------------------------- Controls

//--- sets and static controls

x.set([\orientatio, 2.01])

//--- UGen control with buses


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

//--------------------------- Objects analysis


s.scope
s.queryAllNodes;

x;
x.trace;

k;


Ndef(\sound).play;




x.map(\position, ~busMouseX)
~modulatorSynth.set(\freq, 0.1)


/////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// END /////////////////////////////////////////////
