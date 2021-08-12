function [ff] = feature_mean(inputArg1)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
 nleads=size(inputArg1,1)/10;
 ff=zeros(nleads,size(inputArg1,2));
 m=1;
 for n=1:nleads
     ff(n,:)=mean(inputArg1(m:m+9,:));
     m=m+10;
 end
 %feat=reshape(ff,1,nleads*202);

end