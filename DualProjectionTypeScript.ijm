print("\\Clear")

//	MIT License

//	Copyright (c) 2018 Nicholas Condon n.condon@uq.edu.au

//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:

//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.

//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

scripttitle="IMB_Dual-Projection-Type-Script";
version="0.6";
versiondate="13/08/2018";
description="Details: <br>Takes 1/2/3/4 Channel images, and lets user decide on which channel is brightfield/fluorescence and projects them according to the users input. Brightfield images will be minimum projected, while fluorescence channel projection type can be selected. <br><br>Files to be processed should be in their own directory, processed images will be placed into a subdirectory called Projected_Results_(date and time)"
    
    showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>" 
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The Institute for Molecular Bioscience <br> The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a><\h4>"
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> "
    +"<p1>Version: "+version+" ("+versiondate+")</p1>"
    +"<H2><font size=3>Created by Nicholas Condon</H2>"	
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><\h4> </P4>"
    +"<h3>   <\h3>"    
    +"<p1><font size=3 \b i>"+description+".</p1>"
   	+"<h1><font size=2> </h1>"  
	+"<h0><font size=5> </h0>"
    +"");

//Log Window Title and Acknowledgement
print("");
print("FIJI Macro: "+scripttitle);
print("Version: "+version+" ("+versiondate+")");
print("ACRF: Cancer Biology Imaging Facility");
print("By Nicholas Condon (2018) n.condon@uq.edu.au")
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);
print("");

//Directory Warning and Instruction panel     
Dialog.create("Choosing your working directory.");
 	Dialog.addMessage("Use the next window to navigate to the directory of your images.");
  	Dialog.addMessage("(Note a sub-directory will be made within this folder for output files) ");
  	Dialog.addMessage("Take note of your file extension (eg .tif, .czi)");
Dialog.show(); 


//Setting up File directory locations
run("Clear Results");
path = getDirectory("Choose Source Directory ");
list = getFileList(path);
setBatchMode(true);	

  		
//Main Parameters Dialog
	ext = ".czi";
Dialog.create("Parameters");
	Dialog.addMessage("Select which channel is Fluorescence or brightfield.")
	Dialog.addMessage("Select No Data for any channels not used.")
	Dialog.addChoice("Ch1", newArray("Fluorescence", "Brightfield", "No Data"));
	Dialog.addChoice("Ch2", newArray("Fluorescence", "Brightfield", "No Data"));
	Dialog.addChoice("Ch3", newArray("Fluorescence", "Brightfield", "No Data"));
	Dialog.addChoice("Ch4", newArray("Fluorescence", "Brightfield", "No Data"));
	Dialog.addChoice("Run Z-Projection for Fluoresence Images", newArray("Max Intensity", "Average Intensity", "Sum Slices"));
	Dialog.addMessage("Note: Brightfield Images will be 'Minimum Projected");
	Dialog.addMessage(" ");
	Dialog.addString("Choose your file extension:", ext);
 	Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");
	Dialog.addCheckbox("Add Scale Bar?", false);
	Dialog.addCheckbox("Convert to RGB?", false);	
	Dialog.addCheckbox("Re-Merge Channels?",false);
Dialog.show();

	ext = Dialog.getString();
	ch1 = Dialog.getChoice();
	ch2 = Dialog.getChoice();
	ch3 = Dialog.getChoice();
	ch4 = Dialog.getChoice();
	projectiontype=Dialog.getChoice();
	scale = Dialog.getCheckbox();
	rgb=Dialog.getCheckbox();
	merge=Dialog.getCheckbox();


//Printing Parameters to log file
print("**** Parameters ****")
print("Projection Method: "+projectiontype);
print("File extension: "+ext);
print("Ch1 Image Type = "+ch1);
print("Ch2 Image Type = "+ch2);
print("Ch3 Image Type = "+ch3);
print("Ch4 Image Type = "+ch4);
if (scale == 1) print("Scale Bar: ON");
if (scale == 0) print("Scale Bar: OFF");
if (rgb == 1) print("RGB Conversion: ON");
if (rgb == 0) print("RGB Conversion: OFF");
if (merge == 1) print("Channel Merge: ON");
if (merge == 0) print("Channel Merge: OFF");



//Scale Bar Parameter dialog
if (scale==1){
Dialog.create("Scale Bar Parameters");
	if(ext == ".tif") Dialog.addMessage("WARNING: Make sure your file has the correct metadata for scale");
	Dialog.addMessage("Choose the following parameters for your scale bar");
	Dialog.addString("Line width (microns):", 10);
	Dialog.addString("Line height:", 3);
	Dialog.addChoice("Colour", newArray("White", "Black", "Yellow"));
	Dialog.addChoice("Location", newArray("Lower Right", "Lower Left", "Upper Right", "Upper Left"));
Dialog.show();

	lwidth=Dialog.getString();
	lheight=Dialog.getString();
	colour=Dialog.getChoice();
	location=Dialog.getChoice();

//Printing scale bar parameters into log file
print("Scale Line Width: "+lwidth);
print("Scale Line Height: "+lheight);
print("Scale Line Colour: "+colour);
print("Scale Line Position: "+location);
}

//File Directory Section
start = getTime();
resultsDir = path+"Projected_Results_"+year+"-"+(month+1)+"-"+day+"__"+hour+"."+min+"."+sec+"/";
File.makeDirectory(resultsDir);
print("Working Directory Location: "+path);
print("");


//Running Loop
for (z=0; z<list.length; z++) {
//confirms .tif only files being opened (change to any other format if required)
if (endsWith(list[z],ext)){
 
 open(path+list[z]);
 windowtitle = getTitle();
windowtitlenoext = replace(windowtitle, ext, "");
print("Opening File "+(z+1)+" of "+list.length+": "+windowtitle);

run("Split Channels");


//CH1 Loop
selectWindow("C1-"+windowtitle);
if (ch1 == "Fluorescence"){
	run("Z Project...", "projection=["+projectiontype+"] all");
	if (rgb ==1 ) {run("RGB Color");}
	if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
	saveAs("tiff", resultsDir+windowtitlenoext+"_Ch1_"+projectiontype+".tif");
	print("Saving Ch1 - "+projectiontype+" Projection");
	rename("ch1");
	run("8-bit");
	mloop=1;
	}
if (ch1 == "Brightfield"){
	run("Z Project...", "projection=[Min Intensity] all");
	if (rgb ==1 ) {run("RGB Color");}
	if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
	saveAs("tiff", resultsDir+windowtitlenoext+"_Ch1_Min.tif");
	print("Saving Ch1 - Minimum Intensity Projection");
	rename("ch1");
	run("8-bit");
	mloop=1;
	}	


//ch2 Loop
if(ch2 != "No Data"){
	selectWindow("C2-"+windowtitle);
	if (ch2 == "Fluorescence"){
		run("Z Project...", "projection=["+projectiontype+"] all");
		if (rgb ==1 ) {run("RGB Color");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_Ch2_"+projectiontype+".tif");
		print("Saving Ch2 - "+projectiontype+" Projection");
		rename("ch2");
		run("8-bit");
		mloop=2;
		}
	if (ch2 == "Brightfield"){
		run("Z Project...", "projection=[Min Intensity] all");
		if (rgb ==1 ) {run("RGB Color");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_Ch2_Min.tif");
		print("Saving Ch2 - Minimum Intensity Projection");
		rename("ch2");
		run("8-bit");
		mloop=2;
		}
	}

//ch3 Loop
if(ch3 != "No Data"){
	selectWindow("C3-"+windowtitle);
	if (ch3 == "Fluorescence"){
		run("Z Project...", "projection=["+projectiontype+"] all");
		if (rgb ==1 ) {run("RGB Color");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_Ch3_"+projectiontype+".tif");
		print("Saving Ch3 - "+projectiontype+" Projection");
		rename("ch3");
		run("8-bit");
		mloop=3;
		}
	if (ch3 == "Brightfield"){
		run("Z Project...", "projection=[Min Intensity] all");
		if (rgb ==1 ) {run("RGB Color");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_Ch3_Min.tif");
		print("Saving Ch3 - Minimum Intensity Projection");
		rename("ch3");
		run("8-bit");
		mloop=3;
		}
	}


//ch4 Loop
if(ch4 != "No Data"){
	selectWindow("C3-"+windowtitle);
	if (ch4 == "Fluorescence"){
		run("Z Project...", "projection=["+projectiontype+"] all");
		if (rgb ==1 ) {run("RGB Color");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_Ch4_"+projectiontype+".tif");
		print("Saving Ch4 - "+projectiontype+" Projection");
		rename("ch4");
		run("8-bit");
		mloop=4;
		}		
	if (ch4 == "Brightfield"){
		run("Z Project...", "projection=[Min Intensity] all");
		if (rgb ==1 ) {run("RGB Color");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_Ch4_Min.tif");
		print("Saving Ch4 - Minimum Intensity Projection");
		rename("ch4");
		run("8-bit");
		mloop=4;
		}
	}

	if (mloop==4 && merge ==1) {
		if (rgb ==0 ) {run("Merge Channels...", "c1=ch1 c2=ch2 c3=ch3 c4=ch4 ignore create");}
		if (rgb ==1 ) {run("Merge Channels...", "c1=ch1 c2=ch2 c3=ch3 c4=ch4 ignore all");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_"+projectiontype+"_merge.tif");
	} 
	

	if (mloop==3 && merge ==1) {
		if (rgb ==0 ) {run("Merge Channels...", "c1=ch1 c2=ch2 c3=ch3 ignore create");}
		if (rgb ==1 ) {run("Merge Channels...", "c1=ch1 c2=ch2 c3=ch3 ignore all");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_"+projectiontype+"_merge.tif");
	}

	if (mloop==2 && merge ==1) {
		if (rgb ==0 ) {run("Merge Channels...", "c1=ch1 c2=ch2 ignore create");}
		if (rgb ==1 ) {run("Merge Channels...", "c1=ch1 c2=ch2 ignore all");}
		if (scale==1) {run("Scale Bar...", "width="+lwidth+" height="+lheight+" font=15 color="+colour+" background=None location=["+location+"] hide label");}
		saveAs("tiff", resultsDir+windowtitlenoext+"_"+projectiontype+"_merge.tif");
	}
	
print("");

}}

//exiting loop
print("");
print("Batch Completed");
print("Total Runtime was:");
print((getTime()-start)/1000); 

//saving log file loop
selectWindow("Log");
saveAs("Text", resultsDir+"Log.txt");
title = "Batch Completed";
msg = "Put down that coffee! Your job is finished";
   waitForUser(title, msg);   

