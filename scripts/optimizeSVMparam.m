
ColNames = {'NumFeatures' 'Resolution' 'avgError'};
aroClassifRes = cell2table(cell(0,3),'VariableNames', ColNames);

%%
for f = 5:5:40
   for res=[1 2 5 10 20 50 100]
      fprintf('\n NumFeature:    ');
      fprintf(1,'\b\b\b%d',f); 
      fprintf('\n Resolution:    ');
      fprintf(1,'\b\b\b%d',res);
      aroClassifRes = classifySVM(features2D, labelsLHLH(:,2), f, res, aroClassifRes)
   end
end