% This function calculates engineering strain uses a bounding box
function [CellStepStrain,CellCumStrain,CellBox] = CellBoxStrain(CellBox)
count=0;
tic;

if (isa(CellBox,'table'))
    CellBox = table2struct(CellBox);
end

%Change the slice number when needed
p=[CellBox([CellBox.SliceNumA]==9).CellID];

%%Strain Calculations:
size1=300*length(p);
        CellStepStrain(size1).time=0;
        CellStepStrain(size1).CellID=0;
        CellStepStrain(size1).Exx=0;
        CellStepStrain(size1).Eyy=0;
        CellStepStrain(size1).EA=0;
        
        CellCumStrain(size1).time=0;
        CellCumStrain(size1).CellID=0;
        CellCumStrain(size1).Exx=0;
        CellCumStrain(size1).Eyy=0;
        CellCumStrain(size1).EA=0;
        
        Ex=zeros(length(p));
        Ey=zeros(length(p));
        EArea=zeros(length(p));
        
for jj=2:9 % change 2:(number of your slices)
    for ii=1:length(p)
        %fprintf('jj: %d p: %d .\n',jj,p(ii));
        f=[CellBox([CellBox.SliceNumA]==jj).CellID];
        g=[CellBox([CellBox.SliceNumA]==jj-1).CellID];
        if(ismember(p(ii),f) && ismember(p(ii),g))
            Bx=CellBox([CellBox.SliceNumA]==jj & [CellBox.CellID]==p(ii)).Width;
            By=CellBox([CellBox.SliceNumA]==jj & [CellBox.CellID]==p(ii)).Height;
            Area=CellBox([CellBox.SliceNumA]==jj & [CellBox.CellID]==p(ii)).Area;
            % Calculate step strain
            Bx0=CellBox([CellBox.SliceNumA]==(jj-1) & [CellBox.CellID]==p(ii)).Width;
            By0=CellBox([CellBox.SliceNumA]==(jj-1) & [CellBox.CellID]==p(ii)).Height;
            Area0=CellBox([CellBox.SliceNumA]==(jj-1) & [CellBox.CellID]==p(ii)).Area;
            Ex(ii)=(Bx-Bx0)/Bx0;
            Ey(ii)=(By-By0)/By0;
            EArea(ii)=(Area-Area0)/Area0;
            
            % Calculate cumulative strain
            Bx00=CellBox([CellBox.SliceNumA]==1 & [CellBox.CellID]==p(ii)).Width;
            By00=CellBox([CellBox.SliceNumA]==1 & [CellBox.CellID]==p(ii)).Height;
            Area00=CellBox([CellBox.SliceNumA]==1 & [CellBox.CellID]==p(ii)).Area;
            Exc(ii)=(Bx-Bx00)/Bx00;
            Eyc(ii)=(By-By00)/By00;
            EAreaC(ii)=(Area-Area00)/Area00;
        else
            Bx=0;
            By=0;

            Bx0=0;
            By0=0;
            
            Bx00=0;
            By00=0;
            
        end
    end
    
    for kk=1:length(p)
        count=count+1;
        CellStepStrain(count).time=jj;
        CellStepStrain(count).CellID=p(kk);
        CellStepStrain(count).Exx=Ex(kk);
        CellStepStrain(count).Eyy=Ey(kk);
        CellStepStrain(count).EA=EArea(kk);
        CellCumStrain(count).time=jj;
        CellCumStrain(count).CellID=p(kk);
        CellCumStrain(count).Exx=Exc(kk);
        CellCumStrain(count).Eyy=Eyc(kk);
        CellCumStrain(count).EA=EAreaC(kk);
    end
end
toc
end

csvFile1 = 'CellCumStrain.csv';
writetable(struct2table(CellCumStrain),csvFile1);

csvFile2 = 'CellStepStrain.csv';
writetable(struct2table(CellStepStrain),csvFile2);