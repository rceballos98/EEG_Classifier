function [norm] = normalize_median(M)
     norm = (M > repmat(median(M),size(M,1),1));
end