function [ out ] = ex2( in, str_length )

a = length(in);
out = [char(32*ones(1,str_length-a)), in];