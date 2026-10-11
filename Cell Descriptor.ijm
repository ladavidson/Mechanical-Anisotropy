//FOR SOME REASON IMAGEJ REQUIRES YOU TO OPEN UP THE STUPID ROI MANAGER BEFORE DOING THE VERTEX ANALYSIS. SO OPEN IT.

var reds, greens, blues;

function generateLUT()
{
	reds=newArray(256);
	greens=newArray(256);
	blues=newArray(256);

	for (i=0; i<256; i++) {

		if (i > 2 && i<= 15)
		{
		    reds[i] = 255;
		    greens[i] = 255;
		    blues[i] = 255;
		}
		else
		{
			reds[i] = 0;
		    greens[i] = 0;
		    blues[i] = 0;
		}
    }

}

function generateLUT2()
{
	reds=newArray(256);
	greens=newArray(256);
	blues=newArray(256);

	for (i=3; i<256; i++) {

		if (i == 3)
		{
			reds[i] = 86;
		    greens[i] = 207;
		    blues[i] = 24;
		}
		else if (i ==4)
		{
			reds[i] = 121;
		    greens[i] = 0;
		    blues[i] = 193;
		}
		else if (i >= 5)
		{
			reds[i] = 255;
		    greens[i] = 103;
		    blues[i] = 0;
		}
		else
		{
			reds[i] = 0;
		    greens[i] = 0;
		    blues[i] = 0;
		}


    }

}

function histcount(Cellct2)
{
		tempcount=0;
		histMin=0;
		histMax=0;
		getHistogram(values,counts,Cellct2,histMin,histMax);
		for (i=0; i<values.length; i++)
		{

			if (counts[i]>0)
			{
			tempcount++;
			}
		}
		return tempcount;
}

macro "DVRosettes [1]"
{
	setBatchMode(true);
	folder1=getDirectory("Choose a Directory");
	list1=getFileList(folder1);
	S=getNumber("How big of a circle do you want?", 7);	 // This variable allows you to adjust the size of the square you are passing over the image
	for(q=0;q<list1.length;q++)
	{
		folder0=folder1+list1[q];
		pathname=File.getName(folder0);
		folder=folder0+File.separator+"Segments";
		File.makeDirectory(folder0+"VertROIs");
		folderR=folder0+File.separator+"VertROIs";
		File.makeDirectory(folder0+"Vertex");
		folderV=folder0+File.separator+"Vertex";
		list= getFileList(folder);

		for (n=0;n<list.length;n++)
		{
			roiManager("Reset");  //opens up ROI Manager
			if(n<10)
				{
				open(folder+File.separator+"Segment_0_00"+n+".tif");
				}
			else if ( n< 100)
				{
				open(folder+File.separator+"Segment_0_0"+n+".tif");
				}
			else
				{
				open(folder+File.separator+"Segment_0_"+n+".tif");
				}

			SingleID = getImageID();
			run("Set Measurements...", "min bounding redirect=None decimal=3");
			//run("Measure");
			List.setMeasurements;
			//Declaring Variables
			Cells=List.getValue("Max");
			//getResult("Max");		//Finding the number of cells based on the max intensity in the segments image
			Cellct=(Cells-1);
			Width=List.getValue("Width");
			//getResult("Width");
			Height=List.getValue("Height");
			//getResult("Height");

			j=0;
			//Xmax and Ymax set the end points for the square
			Xmax=Width-S;
			Ymax=Height-S;

			//creating new image to create color coded junction squares
			newImage("Blank", "8-bit black",Width, Height, 1);
			FilledID = getImageID();
			start=getTime();
			newImage("Blank", "8-bit black",Width, Height, 1);
			FilledID2 = getImageID();

			print(Cells,Cellct,Xmax,Ymax);
			/*This next part causes the square to traverse through the image first moving  pixel by pixel down the y direction then over one pixel to the right and down again.
			 * As it moves down it checks the histogram for the number of intensities within the cell. It increments a counter each time it finds a new intensity. */

			for (y = 0; y < Ymax; y++)
			{
				/*if(y%50==0)
				{
					print("y= "+y);
				}*/
				for (x = 0; x < Xmax; x++)
				{
					selectImage(SingleID);
					makeOval(x-(S/2), y-(S/2), S, S);
					ros=0;
					ros=histcount(Cellct);

					/*This next part checks if the square has overlapped more than 4 cells. If it does It will add the square to the ROI manager
					 and then draw that square on the blank image. The intensity of the rectangle outline will equal the number of cells in that rosette.
					 you can use a look up table to assign a specific color to each number */
					if (ros>2)
					{
						setColor(ros, ros, ros);
			    		 	roiManager("Add");
						selectImage(FilledID);
						//drawOval(x, y, S, S);
						setPixel(x,y,ros);

					}
				}
			}
			//Array.show("Rosette Nums", Ros, xarray, yarray);
			// selectWindow("Rosette Nums");
			//saveAs("Results", folder0+"\\pixRosettenums.txt");
			//roiManager("Select All");
			//roiManager("Save", folder0+"/rosettecircles"+S+"_"+n+".zip");
			//roiManager("Reset");

			generateLUT();
		//Here we are identifying all   of the vertices in the image
			selectImage(FilledID);

			setLut(reds, greens, blues);
			run("8-bit");

			run("Make Binary");
			roiManager("Deselect");
			roiManager("Show All with labels");
			roiManager("Show All");
			run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing clear add");
			roiManager("Select All");
			roiManager("Save", folderR+File.separator+pathname+"vertices"+S+"_"+n+".zip");

			selectImage(FilledID);
			//saveAs("Tiff", folder0+"/pixrosette"+S+"_"+n+".tif");
			run("Close");

		//Here we go through and determine how many intensities are in the vertex ROI
			nrois=roiManager("count");
			for(i=0; i<nrois;i++)
			{
				intensitycount=0;
				selectImage(SingleID);
				roiManager("Select", i);
				intensitycount=histcount(Cellct);


					roiManager("Select",i);
					List.setMeasurements;

					fillv=getResult("Max");
					setForegroundColor(intensitycount, intensitycount, intensitycount);
					run("Select None");
					selectImage(FilledID2);
					roiManager("Select", i);
					setColor(intensitycount);
					run("Fill", "slice");
					run("Select None");
			}

			selectImage(SingleID);
			run("Close");
			roiManager("Reset");

			generateLUT2();
			selectImage(FilledID2);
			setLut(reds, greens, blues);
			saveAs("Tiff", folderV+File.separator+pathname+"_Vertex"+S+"_"+n+".tif");

			//print("Done with frame "+n);

		}

			print("Done with folder " +q);
	}
	print("ALL FINISHED!!");
		setBatchMode(false);
}


macro "Cell ROIs [2]"
{

	setBatchMode(true);
	setOption("ExpandableArrays", true);
	folder1=getDirectory("Choose a Directory");
	list1=getFileList(folder1);
	scale=getNumber("set scale", 1); //2.239
	mid=getNumber("where's the midline?", 450); //650

	run("Overlay Options...", "stroke=yellow width=0 fill=none set");
	for (q=0; q<list1.length;q++)
	{
			var major=newArray;
			var minor=newArray;
			var Area=newArray;
			var Angle=newArray;
			var AspectRatio=newArray;
			var CentroidX=newArray;
			var CentroidY=newArray;
			var CellNum=newArray;
			var CellID=newArray;
			var RelX=newArray;
			var SliceNumA=newArray;

			arraycount = 0;

		folder0=folder1+list1[q];
		pathname=File.getName(folder0);
		folder=folder0+File.separator+"Outlines";
		File.makeDirectory(folder0 + "CellROIs");
		folderR=folder0+File.separator+"CellROIs";
		list= getFileList(folder);
		stack1=folder0+"Segments"+File.separator;
    	run("Image Sequence...", "open=&stack1 sort");
		SegID = getImageID();
		selectImage(SegID);
		saveAs("tiff", folder0+"Segments.tif");
		for (n=0;n<list.length;n++)
		{
			var delarray= newArray;
			dcount=0;
			if(n<10)
				{
				open(folder+File.separator+"Outline_0_00"+n+".tif");
				SingleID = getImageID();
				}
			else if ( n< 100)
				{
				open(folder+File.separator+"Outline_0_0"+n+".tif");
				SingleID = getImageID();
				}
			else
				{
				open(folder+File.separator+"Outline_0_"+n+".tif");
				SingleID = getImageID();
				}

				//STARTING HERE IS THE CORE CODE OF TURNING OUTLINE IMAGE INTO ROIS
			setAutoThreshold("Default dark");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			run("Skeletonize");
			run("Dilate");
			//run("Create Selection");
			//run("Enlarge...", "enlarge=1");
			//setForegroundColor(255, 255, 255);
			//run("Fill", "slice");
			//run("Select None");
			run("Invert");
			run("Analyze Particles...", "size=7-25000 circularity=0.00-1.00 show=Nothing display exclude clear summarize add");

			selectWindow("Results");
			run("Close");

			selectImage(SegID);
			slicenum=n+1;
			setSlice(slicenum);
			run("Set Measurements...", "area modal centroid fit redirect=None decimal=2");

			nrois=roiManager("count");

			for (p=0;p<nrois;p++)
			{
				arraycount++;

				CellNum[arraycount]=p+1;
				SliceNumA[arraycount]=n;
				roiManager("Select", p);
				roiManager("Update");
				List.setMeasurements;
				f=scale*scale;
				Area[arraycount]=List.getValue("Area")/f;
				major[arraycount]=List.getValue("Major");
				minor[arraycount]=List.getValue("Minor");
				CellID[arraycount]=List.getValue("Mode");
				CentroidX[arraycount]=List.getValue("X")/scale;
				CentroidY[arraycount]=List.getValue("Y")/scale;
				RelX[arraycount]= abs(CentroidX[arraycount]-mid);
				AspectRatio[arraycount]=major[arraycount]/minor[arraycount];
				angle1=List.getValue("Angle");
				if (angle1 > 90) {
					Angle[arraycount]=abs(180-angle1);
				}
				else{
					Angle[arraycount]=angle1;
					}

				//renaming the ROI to its cell ID
				if (CellID[arraycount]==1)
				{
							delarray[dcount]=p;
							dcount++;
				}

				name = d2s(CellID[arraycount],0);
				roiManager("select", p);
				roiManager("Rename", name);
			}
					if (delarray.length>0)
					{
						roiManager("select", delarray);
						roiManager("delete");
					}
			roiManager("Select All");
			roiManager("Save", folderR+File.separator+"cellROIs"+n+".zip");

			roiManager("reset");
			selectImage(SingleID);

			close();

		}
			Array.show("Cell Morphology",SliceNumA, CellNum, CellID ,CentroidX, CentroidY,Area, major, minor,AspectRatio,Angle,RelX);
			selectWindow("Cell Morphology");
			saveAs("Results", folder0+"CellMorphology"+"_"+pathname+".txt");
			selectWindow("CellMorphology"+"_"+pathname+".txt");
			run("Close");
			print("Done with folder "+q);

	}

	print("Done with all folders");

	setBatchMode(false);
}
