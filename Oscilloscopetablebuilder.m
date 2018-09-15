% Table of all available oscilloscope controls
handles.averagenum=[4; 16; 64; 128];
handles.averagenumcase=[1; 2; 3; 4];
handles.voltnum=[0.0020; 0.0050; 0.0100; 0.0200; 0.0500; 0.1000; 0.2000; 0.5000; 1; 2; 5; 10; 20; 50];
handles.voltname={'2 miliVolts'; '5 miliVolts'; '10 miliVolts'; '20 miliVolts'; '50 miliVolts'; '100 miliVolts'; '200 miliVolts'; '500 miliVolts'; '1 Volt'; '2 Volts'; '5 Volts'; '10 Volts'; '20 Volts'; '50 Volts'};
handles.voltnumcase=[1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11];
handles.timebasenum=[5.0000e-009; 1.0000e-008; 2.5000e-008; 5.0000e-008; 1.0000e-007; 2.5000e-007; 5.0000e-007; 1.0000e-006; 2.5000e-006; 5.0000e-006; 1.0000e-005; 2.5000e-005; 5.0000e-005; 1.0000e-004; 2.5000e-004; 5.0000e-004; 1.0000e-003; 0.0025; 0.0050; 0.0100; 0.0250; 0.0500];
handles.timebasenumname={'5 nanoseconds'; '10 nanoseconds'; '25 nanoseconds'; '50 nanoseconds'; '100 nanoseconds'; '250 nanoseconds'; '500 nanoseconds'; '1 microsecond'; '2.5 microseconds'; '5 microseconds'; '10 microseconds'; '25 microseconds'; '50 microseconds'; '100 microseconds'; '250 microseconds'; '500 microseconds'; '1 milisecond'; '2.5 miliseconds'; '5 miliseconds'; '10 miliseconds'; '25 miliseconds'; '50 miliseconds'};
handles.timebasenumcase=[1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22];
handles.channelnum=[1; 2];
handles.channelname={'channel1'; 'channel2'};
handles.aqmodenum={'SAMPLE'; 'AVERAGE'};
handles.aqmodenumcase={'Sample'; 'Average'};
handles.aqmodenumber=[1; 2];
save('oscilloscopecontrol.mat');
%clearvars averagenum averagenumcase voltnum voltnumname voltnumcase timebasenum timebasenumname timebasenumcase channelnum channelname aqmodenum aqmodenumcase aqmodenumber