function [premat]=fntnfun(typemat,typemat2)
% Calculate BP confusion matrix
set1=sort(unique(typemat));% All types
n=length(set1);
premat=zeros(n,n);
for i=1:n
    h1= typemat==set1(i);
    mat2= typemat2(h1);
    set2=sort(unique(mat2));
    n2=length(set2);
    for j=1:n2
        h2= mat2==set2(j);
        premat(set1(i),set2(j))=sum(h2);% the number of set1(i) that is classified as set2(j)
    end
end


