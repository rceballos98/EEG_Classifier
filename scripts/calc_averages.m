table = valAccuracyMatrixAllSubAllFea;
for i = 1:size(table)
    vec = table2array(table(i,5:21));
    table(i,:).avgError = mean(vec);
    table(i,:).SD = std(vec);
end
valAccuracyMatrixAllSubAllFea = table