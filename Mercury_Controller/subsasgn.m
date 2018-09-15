function c = subsasgn(c, S,val)
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
        if(length(par)<1)
            error(sprintf('No axis given for %s command',fun));
        end
        POS(c,char(par),val);
    case('SERVO')
        if(length(par)<1)
            error(sprintf('No axis given for %s command',fun));
        end
        SVO(c,char(par),val);
    case('TARGETPOSITION')
        if(length(par)<1)
            error(sprintf('No axis given for %s command',fun));
        end
        MOV(c,char(par),val);
    case('VELOCITY')
        if(length(par)<1)
            error(sprintf('No axis given for %s command',fun));
        end
        VEL(c,char(par),val);
    case('RELATIVETARGET')
        if(length(par)<1)
            error(sprintf('No axis given for %s command',fun));
        end
        MVR(c,char(par),val);
    case('RECORDTABLERATE')
        RTR(c,val);
end