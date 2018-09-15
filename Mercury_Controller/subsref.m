function val = subsref(c, S)
% function subsref(c, S)
% keyboard;
par = '';
for n = 1:length(S)
    switch S(n).type
        case '.'
            fun = S(n).subs;
        case '()'
            par = S(n).subs;
    end
end
switch(upper(fun))
    case('ACTUALPOSITION')
%         disp(['qPOS(',par,')']);
        val = qPOS(c,char(par));
    case('TARGETPOSITION')
%         disp(['qMOV(',par,')']);
        val = qMOV(c,char(par));
    case('IDENTIFICATION')
%         disp(['qMOV(',par,')']);
        val = c.IDN;
    case('SERVO')
%         disp(['qMOV(',par,')']);
        val = qSVO(c,char(par));
    case('ISREFERENCING')
%         disp(['qMOV(',par,')']);
        val = IsReferencing(c,char(par));
    case('ISMOVING')
%          disp(['qONT(',par,')']);
        val = qONT(c,char(par));
        val = ~val;
    case('MINPOSITION')
        val = qTMN(c,char(par));    
    case('MAXPOSITION')
        val = qTMX(c,char(par)); 
end