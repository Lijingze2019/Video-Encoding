SetMemoryMax(6000)

global threads=25

LoadPlugin("F:\Programme Files\SVP 4\plugins64\svpflow1.dll")
LoadPlugin("F:\Programme Files\SVP 4\plugins64\svpflow2.dll")

SetFilterMTMode("DEFAULT_MT_MODE",2)
SetFilterMTMode("SVSuper",1)
SetFilterMTMode("SVAnalyse",1)
SetFilterMTMode("ffdshow_source",3)
ffdshow_source()

ConvertToYV12()

global crop_string  = ""
global resize_string = ""
global super_params     = "{scale:{up:0},gpu:1,rc:true}"
global analyse_params   = "{block:{overlap:0},main:{search:{coarse:{distance:-8,bad:{sad:2000,range:24}},type:2}}}"
global smoothfps_params = "{gpuid:11,rate:{num:3,den:1},algo:23,mask:{area:25,cover:80},scene:{blend:true,limits:{m1:0,m2:0}}}"

global demo_mode=0
global stereo_type=0

########## BEGIN OF base.avs ##########
# This file is a part of SmoothVideo Project (SVP) ver.4
# This is NOT the full AVS script, all used variables are defined via
# JScript code that generates the full script text.

function interpolate(clip src)
{
	input = crop_string=="" ? src : eval("src."+crop_string)
	input = resize_string=="" ? input : eval("input."+resize_string)

	#MT-MODE-1  #do not remove this line!

	super=SVSuper(input, super_params)
	vectors=SVAnalyse(super, analyse_params, src=input)
	smooth=SVSmoothFps(input, super, vectors, smoothfps_params, mt=threads, src=src)

	#MT-MODE-2  #do not remove this line!

	return demo_mode==0 ? smooth : demo(input,smooth)
}

input=last

	stereo_type==0 ? eval(""" interpolate(input)
""") : 	stereo_type==1 ? eval("""
		lf = interpolate(input.crop(0,0,input.width/2,0))
		rf = interpolate(input.crop(input.width/2,0,0,0))
		StackHorizontal(lf, rf)
""") : 	stereo_type==2 ? Eval("""
		lf = interpolate(input.crop(0,0,0,input.height/2))
		rf = interpolate(input.crop(0,input.height/2,0,0))
		StackVertical(lf, rf)""") : input

########### END OF base.avs ###########


Prefetch(threads)