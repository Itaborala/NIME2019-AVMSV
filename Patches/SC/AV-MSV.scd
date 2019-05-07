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

~folder = "../Sons/ESTRUTURAS/VOZ_LUANA/";
//~folder = "../Sons/Vasos_Camila/;

(var paths, soundPath;

~paths = List[];

//paths = Pipe.new("ls ../Sons/Vozes_Luana_BRC_Estudios/", "r");
paths = Pipe.new("ls ../Sons/ESTRUTURAS/VOZ_LUANA", "r");


soundPath = paths.getLine;

while({soundPath.notNil}, {~paths = ~paths.add(soundPath); soundPath = paths.getLine;});

paths.close;

~paths;
)

/////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// SYNTHDEF SECTION //////////////////////////////////////////



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


/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// EXPLORING AND TUTORIALS SECTION ////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// END /////////////////////////////////////////////
