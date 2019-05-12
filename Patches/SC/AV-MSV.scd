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

Ndef(\modulator, {
	SinOsc.kr(\freq.kr(1)).range(-3,3);
}).add;

Ndef(\control_mouseXs1, {
	MouseX.kr(-1, 1);
}).add;

)


/////////////////////////////////////////////////////////////////////////////////////////////////

//NDEF VERSION




~pbuf6 = Ndef(\playbuf6);
~pbuf6.fadeTime = 2;
~pbuf6.addSpec(\position, [-1, 1, \lin]);
~pbuf6.addSpec(\bufnum, [0, 1, \lin]);
NdefPreset.new(Ndef(\playbuf6), [\bufnum, \position]);
~pbuf6Preset = NdefPreset(Ndef(\playbuf6));
~pbuf6Preset.addSet(\cucu, [[\bufnum, 0], [\position, -1]]);
~pbuf6Preset.addSet(\coco, [[\bufnum, 0], [\position, -0.5]]);


~pbuf6Preset.settings.printcsAll;"";
NdefPreset.all
NdefPreset.all.clear

//-------------------------- Start a Synth function

(
{
var len;
len = ~paths.size;

m = {
	arg buf;
	buf.close;


	r=Ndef(\playbuf6, {

	PanAz.ar(6, PlayBuf.ar(1, buf.bufnum, trigger: \trigg.ar(1)), pos: \position.kr(-1), orientation: \orientatio.kr(-3.0) );
	});


};

k = Buffer.read(s, ~folder +/+ ~paths.wchoose(1/len !len ), action: m);
}
)






Ndef(\playbuf6).fadeTime = 3;
r.set(\bufnum, 1);

Ndef(\playbuf6).controlKeys
Ndef(\playbuf6).set(\position, -1)
k
Ndef(\playbuf6).set(\bufnum, 2)
//--------------------------- Controls

//--- sets and static controls

x.set([\orientatio, 2.01])
w.set([\bufnum, 1])
//--- UGen control with buses

n = NodeProxy.new;
n.play;
n.fadeTime = 1;
r = Ndef(\playbuf6)
n.source = v;
n.source = Ndef(\playbuf6, v)
n.source = {Impulse.ar(1)}
v.set([\bufnum, 2])

Ndef(\playbuf6).set(\trigg, 0)
NdefPreset.new(Ndef(\playbuf6), [\bufnum, \position])
NdefPreset(Ndef(\playbuf6)).settingsString
NdefPreset(Ndef(\playbuf6)).checkSpecsMissing
NdefPreset(Ndef(\playbuf6)).namesToStore
NdefPreset(Ndef(\playbuf6)).getCurr
NdefPreset.all
NdefPreset.all.clear
NdefPreset(Ndef(\playbuf6)).getSetNames
NdefPreset(Ndef(\playbuf6)).settings.printcsAll;"";
NdefPreset(Ndef(\playbuf6)).addSet(\cucu, [[\bufnum, 0], [\position, -1]])
NdefPreset(Ndef(\playbuf6)).addSet(\coco, [[\bufnum, 1], [\position, -1]])
NdefPreset(Ndef(\playbuf6)).xfadeTo(\coco, 3)
NdefPreset(Ndef(\playbuf6)).setCurr(\coco)
NdefPreset(Ndef(\playbuf6)).setCurr(\cocu)
NdefPreset(Ndef(\playbuf6)).setCurr(\cucu)
NdefPreset(Ndef(\playbuf6)).morph(0.5, \coco, \cucu, false)
Ndef(\playbuf6).addSpec(\position, [-1, 1, \lin])
Ndef(\playbuf6).addSpec(\bufnum, [0, 1, \lin])
Ndef(\playbuf6).fadeTime = 1
Ndef(\playbuf6).set(\bufnum, 1.1)




~pbpr = NdefPreset



r = Ndef(\playbuf6)
r.play


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
