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
///////////////////////////// FUNCTIONS EXPERIMENTS SECTION /////////////////////////////////////


(var paths, soundPath;

~paths = List[];

//paths = Pipe.new("ls ../Sons/Vozes_Luana_BRC_Estudios/", "r");
paths = Pipe.new("ls ../Sons/ESTRUTURAS/VOZ_LUANA", "r");


soundPath = paths.getLine;

while({soundPath.notNil}, {~paths = ~paths.add(soundPath); soundPath = paths.getLine;});

paths.close;

~paths;
)
~paths.size
~paths.wchoose(1/12!12)
~paths.wchoose([0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0])

1/12!12

(var len;

len = ~paths.size;
k = Buffer.cueSoundFile(s, "/home/itaborala/NIME2019-AVMSV/Sons/ESTRUTURAS/VOZ_LUANA/" ++ ~paths.wchoose(1/len !len ));
//"../Sons/Vozes_Luana_BRC_Estudios" ++ "d"
)

(var len;

len = ~paths.size;
k = Buffer.read(s, "../Sons/ESTRUTURAS/VOZ_LUANA/" ++ ~paths.wchoose(1/len !len ));

)



k.plot
k.bufnum
k.close
y = { PlayBuf.ar(1, 30) }.play
x = { DiskIn.ar(1, 29) }.play;

x.free
y.free
/////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// SYNTHDEF EXPERIMENTS SECTION /////////////////////////////////////

OpenObject.start





/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// EXPLORING AND TUTORIALS SECTION ////////////////////////////////////
~buz = Bus.audio(s, 6)
~buz.free

/////////////////////OpenObject Example

Quarks.install("OpenObject");
Quarks.install("sc3plugins");
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



/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// END /////////////////////////////////////////////
