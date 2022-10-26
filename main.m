clear all;
close all;
packet = Packet();
transmitted = packet.data;
fprintf("Transmitted Strings:\n");
printstr(bits2string(transmitted));
fprintf("---------------------------------------------------------\n");

packet.construction();
packet.transmission();
packet.detection();
packet.synchronization();
packet.decoding();

received = packet.data;
fprintf("Received Strings:\n");
printstr(bits2string(received));
fprintf("---------------------------------------------------------\n");
fprintf("Error Rate : %d\n", mean(transmitted~=received));

function str = bits2string(bits)
    %disp(bits)
    str = char(bin2dec(num2str(reshape(bits,[],8)))).';
end

function []=printstr(str)
    fprintf('%s\n',str(1:80));
    fprintf('%s\n',str(81:160));
    fprintf('%s\n',str(161:240));
    fprintf('%s\n',str(241:320));
    fprintf('%s\n',str(321:400));
    fprintf('%s\n',str(401:480));
end