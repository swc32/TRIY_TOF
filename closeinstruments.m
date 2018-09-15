function [] = closeinstruments()

instruments = instrfind;   %%

if ~isempty(instruments)
ind=find(ismember(instruments.status,'open'));


if ~isempty(ind)
instruments
fclose(instruments)
end

end
end