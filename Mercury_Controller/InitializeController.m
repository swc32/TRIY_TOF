function c = InitializeController(c)
%function c = InitializeController(c)
c.IDN = qIDN(c);
szAxes = qSAI_ALL(c);
c.NumberOfAxes = length(szAxes);