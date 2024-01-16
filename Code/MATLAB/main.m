clc
clear all
close all

%255 02 01 08 07 01 15 10 12 13 01 03 14 15 03 05
arr = [15 45 30 50 60 40];
%arr = [255 02 01 08 07 01 15 10 12 13 01 03 14 15 03 05];
len = size(arr,2);

arr1 = quick_sort(arr, 1, len);