//Open the real data stack and all the cellROIs zip files for all frames to generate this data 	
			
			setOption("ExpandableArrays", true); 
			var major=newArray;
			var minor=newArray;
			var Area=newArray;
			var Angle=newArray;
			var CentroidX=newArray;
			var CentroidY=newArray;
			var CellNum=newArray;
			var CellID=newArray;
			var Width=newArray;
			var Height=newArray;
			var SliceNumA=newArray;
			var mean=newArray;
			var Perimeter=newArray;
			nrois=roiManager("count");
			//print(nrois);

			for (arraycount=0;arraycount<nrois;arraycount++)
			{

				roiManager("Select", arraycount);
				//run("Set Measurements...", "area modal centroid fit stack redirect=None decimal=2");
				//run("Measure");
				SliceNumA[arraycount]=getSliceNumber();
				List.setMeasurements;
				Area[arraycount]=List.getValue("Area");
				major[arraycount]=List.getValue("Major");
				minor[arraycount]=List.getValue("Minor");
				CellID[arraycount]=Roi.getName();
				CentroidX[arraycount]=List.getValue("X");
				CentroidY[arraycount]=List.getValue("Y");
				Angle[arraycount]=List.getValue("Angle");
				Width[arraycount]=List.getValue("Width");
				Height[arraycount]=List.getValue("Height");
				Perimeter[arraycount]=List.getValue("Perim.");
				mean[arraycount]=List.getValue("Mean");
			}

Array.show("CellBox",SliceNumA, CellID ,CentroidX, CentroidY,Angle, major, minor,Area,Width,Height,Perimeter,mean); 
			selectWindow("CellBox");
		//	saveAs("Results", cfold+"/CellBox.txt");