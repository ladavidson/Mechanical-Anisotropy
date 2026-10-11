//Color code cell ROI with MATLAB Exx step strain values 

//!!!Important: Open all you ROI.zip folders in ROI Manager (except the last one)
//!!!Important: Open your matlab csv file in FIJI as well
//!!!Important: Delete all NaN rows in the csv file

// Create a dialog box to ask for the slice number and image size
Dialog.create("Enter Slice Number and Image Size");
Dialog.addNumber("Slice Number:", 1);
Dialog.addNumber("Image Width:", 1);
Dialog.addNumber("Image Height:", 1);
Dialog.show();

// Get the user's input
var sliceNumber = 0;
var Iwidth = 0;
var Iheight = 0;
sliceNumber = Dialog.getNumber();
Iwidth = Dialog.getNumber();
Iheight = Dialog.getNumber();

// Check if the input is valid
if (sliceNumber <= 0 || sliceNumber > 999) {
    print("Invalid slice number!");
} else {
    // make a new image stack with the user input
    newImage("HyperStack", "32-bit composite-mode", Iwidth, Iheight, 1, sliceNumber - 1, 1);
    selectWindow("HyperStack");
//    for(k=1;k<nSlices+1;k++) {
//		Stack.setSlice(k);
//		run("Select All");
//		changeValues(0, 4294967295, -3);
//    }
    rename("Matlab_Exx Strain");
}

run("Select None");
selectWindow("Matlab_Exx Strain");

// Fill the roi with cellular strain values from Matlab
var csvCount = 0;
var nrois = 0;
var t = 0;
var CellID = 0;
var roiName = 0;
var Exx = 0;

// Count rows in csv files and roi manager
selectWindow("CellStepStrain.csv");
csvCount = getValue("results.count");
nrois = roiManager("count");

//Loop through csv files first
for(i = 0; i < csvCount; i++) {
	roiManager("Deselect");
	t = getResult("time", i);
	CellID = getResult("CellID", i);
	//Loop through Rois
	for(j = 0; j < nrois; j++) {
		roiManager("Select", j);
		roiName = Roi.getName(); //get Roi's name, it should be the same as CellID in the csv file
		Roi.getPosition(channel,slice,frame); //slice should be the same as time in the csv file
		//Check if CellID = Roi's Name & time = slice
		if(matches(CellID,roiName) && matches(t-1,slice)) {
			Exx = getResult("Exx",i);
			//expand the roi by 1 pixel in all directions to fill the junction line
			run("Enlarge...", "enlarge=1");
			//Change roi values to the Exx value from MATLAB
			changeValues(-200, 4294967295, Exx);
			roiManager("deselect");
		}
	}
}

run("Select None");

//Get min and max values
//!!!Important: These values should be equal to the values in StrainMapper!!
Dialog.create("Enter min and max values");
Dialog.addNumber("B&C Min:", 1);
Dialog.addNumber("B&C Max (=-Min):", 1);
Dialog.show();

var iMin = 0;
var iMax = 0;
iMin = Dialog.getNumber();
iMax = Dialog.getNumber();
if(abs(iMin) != abs(iMax)) {
	print("The absolute value of min and max should be equal!");
} else{
	setMinAndMax(iMin,iMax);
	run("phase");
}


