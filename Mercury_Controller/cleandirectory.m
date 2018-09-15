generatedfiles = dir('*.m');
belowfiles = dir('..\\*.m');
for n = 1:length(generatedfiles)
    name = generatedfiles(n).name
    for m = 1:length(belowfiles)
        if(strcmp(belowfiles(m).name,name)~=0)
            delete(['..\\',belowfiles(m).name]);
        end
    end
end

copyfile('..\\*.m','..\\created\\');
movefile('..\\*.asv','..\\asv\\');

