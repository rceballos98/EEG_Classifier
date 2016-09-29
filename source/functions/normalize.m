function norm = normalize(M)
    norm = (M - repmat(mean(M),size(M,1),1))./repmat(range(M),size(M,1),1);
end