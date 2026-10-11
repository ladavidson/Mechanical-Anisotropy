
var nrois = 0;
nrois = roiManager("count");
for(i=0;i<nrois;i++){
	roiManager("Select", i);
	run("Enlarge...", "enlarge=2");
	roiManager("Add");
}

roiManager("Select All");
roiManager("Combine");
roiManager("Add");
run("Select None");
roiManager("Select",2*i);
Roi.setStrokeColor("black");





