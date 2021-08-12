function [x] = isnan1(x)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
x(find(isnan(x)))=0;