function [out loc1] = Pwave( ecg, fs )
% 
% Copyright (C) 2017 
% Shreyasi Datta
% Chetanya Puri
% Ayan Mukherjee
% Rohan Banerjee
% Anirban Dutta Choudhury
% Arijit Ukil
% Soma Bandyopadhyay
% Rituraj Singh
% Arpan Pal
% Sundeep Khandelwal
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

plotvar = 0;
loc = [];
[QRS,sign,en_thres,bpfecg,Q,S] = qrs_detect3(ecg',0.25,0.6,fs);
amp = ecg(QRS);
if mean(amp) < 0 && median(amp) < 0
    ecg = -ecg;
    [QRS,sign,en_thres,bpfecg,Q,S] = qrs_detect3(ecg',0.25,0.6,fs);
end

[b,a] = butter(1,15/fs,'low');
ecg1 = filtfilt(b,a,ecg);
diffecg = [0; diff(ecg1)];
ind1 = [];
% for i = 1 : length(diffecg)-1
%    if diffecg(i)>=0 && diffecg(i+1)<0
%        ind1 = [ind1 i];
%    end
% end
[xymax,ind1,xymin,smin] = extrema(ecg1);


for i = 1 : length(QRS)-1
    temp_ind = intersect(find(ind1>QRS(i)),find(ind1<QRS(i+1)));
    temp_ind = ind1(temp_ind);
    dist = QRS(i+1)-QRS(i);
    reoveind = intersect(temp_ind,QRS(i):QRS(i)+round(0.7*dist));
    reoveind = union(reoveind,intersect(temp_ind,QRS(i)+round(0.95*dist):QRS(i+1)));
    for j = 1 :  length(reoveind)
        temp_ind(find(temp_ind==reoveind(j))) = [];
    end
    if ~isempty(temp_ind)
        temp_ind = temp_ind(end);
    end
    loc = [loc temp_ind];
    temp_ind = [];
end

out = length(loc)/length(QRS);


% plot(ecg); hold on;
% %plot(diffecg,'r');
% plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',3);%,'MarkerFaceColor','b');
% plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);


% L = floor(length(ecg)/fs);
% ecg = ecg(1:L*fs);
L = length(ecg)/fs;
loc1 = loc;
QRS1 = QRS;
ecg1 = ecg;


%% Plotting

if plotvar == 1
    figure;

    if L >= 8 && L < 16
        
        subplot(2,1,1);hold on;
        ecg = ecg1(1:8*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(find(loc1<8*fs));
        QRS = QRS1(find(QRS<8*fs));
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'0','1','2','3','4','5','6','7','8'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(2,1,2);hold on;
        ecg = ecg1(8*fs+1:end);
        plot(ecg);xlim([0 2400]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>8*fs),find(loc1<length(ecg1))));
        QRS = QRS1(intersect(find(QRS1>8*fs),find(QRS1<length(ecg1))));
        loc = loc - fs*8;
        QRS = QRS - fs*8;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'8','9','10','11','12','13','14','15','16'});
        xlabel('Time (seconds)','Fontsize',12);
               
    elseif L >= 16 && L < 24
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        
        subplot(3,1,1);hold on;
        ecg = ecg1(1:8*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(find(loc1<8*fs));
        QRS = QRS1(find(QRS<8*fs));
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'0','1','2','3','4','5','6','7','8'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(3,1,2);hold on;
        ecg = ecg1(8*fs+1:16*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>8*fs),find(loc1<16*fs)));
        QRS = QRS1(intersect(find(QRS1>8*fs),find(QRS1<16*fs)));
        loc = loc - fs*8;
        QRS = QRS - fs*8;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'8','9','10','11','12','13','14','15','16'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(3,1,3);hold on;
        ecg = ecg1(16*fs+1:end);
        plot(ecg);xlim([0 2400]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>16*fs),find(loc1<length(ecg1))));
        QRS = QRS1(intersect(find(QRS1>16*fs),find(QRS1<length(ecg1))));
        loc = loc - fs*16;
        QRS = QRS - fs*16;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'16','17','18','19','20','21','22','23','24'});
        xlabel('Time (seconds)','Fontsize',12);
        
    elseif L >= 24 && L < 32
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        
        subplot(4,1,1);hold on;
        ecg = ecg1(1:8*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(find(loc1<8*fs));
        QRS = QRS1(find(QRS<8*fs));
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'0','1','2','3','4','5','6','7','8'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(4,1,2);hold on;
        ecg = ecg1(8*fs+1:16*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>8*fs),find(loc1<16*fs)));
        QRS = QRS1(intersect(find(QRS1>8*fs),find(QRS1<16*fs)));
        loc = loc - fs*8;
        QRS = QRS - fs*8;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'8','9','10','11','12','13','14','15','16'});
        xlabel('Time (seconds)','Fontsize',12);
                
        subplot(4,1,3);hold on;
        ecg = ecg1(16*fs+1:24*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>16*fs),find(loc1<24*fs)));
        QRS = QRS1(intersect(find(QRS1>16*fs),find(QRS1<24*fs)));
        loc = loc - fs*16;
        QRS = QRS - fs*16;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'16','17','18','19','20','21','22','23','24'});
        xlabel('Time (seconds)','Fontsize',12);
        
        
        subplot(4,1,4);hold on;
        ecg = ecg1(24*fs+1:end);
        plot(ecg);xlim([0 2400]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>24*fs),find(loc1<length(ecg1))));
        QRS = QRS1(intersect(find(QRS1>24*fs),find(QRS1<length(ecg1))));
        loc = loc - fs*24;
        QRS = QRS - fs*24;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'24','25','26','27','28','29','30','31','32'});
        xlabel('Time (seconds)','Fontsize',12);
             
    elseif L>=32 && L < 40
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
               
        subplot(5,1,1);hold on;
        ecg = ecg1(1:8*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(find(loc1<8*fs));
        QRS = QRS1(find(QRS<8*fs));
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'0','1','2','3','4','5','6','7','8'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(5,1,2);hold on;
        ecg = ecg1(8*fs+1:16*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>8*fs),find(loc1<16*fs)));
        QRS = QRS1(intersect(find(QRS1>8*fs),find(QRS1<16*fs)));
        loc = loc - fs*8;
        QRS = QRS - fs*8;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'8','9','10','11','12','13','14','15','16'});
        xlabel('Time (seconds)','Fontsize',12);
        
        
        subplot(5,1,3);hold on;
        ecg = ecg1(16*fs+1:24*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>16*fs),find(loc1<24*fs)));
        QRS = QRS1(intersect(find(QRS1>16*fs),find(QRS1<24*fs)));
        loc = loc - fs*16;
        QRS = QRS - fs*16;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'16','17','18','19','20','21','22','23','24'});
        xlabel('Time (seconds)','Fontsize',12);
                
        subplot(5,1,4);hold on;
        ecg = ecg1(24*fs+1:32*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>24*fs),find(loc1<32*fs)));
        QRS = QRS1(intersect(find(QRS1>24*fs),find(QRS1<32*fs)));
        loc = loc - fs*24;
        QRS = QRS - fs*24;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'24','25','26','27','28','29','30','31','32'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(5,1,5);hold on;
        ecg = ecg1(32*fs+1:end);
        plot(ecg);xlim([0 2400]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>32*fs),find(loc1<length(ecg1))));
        QRS = QRS1(intersect(find(QRS1>32*fs),find(QRS1<length(ecg1))));
        loc = loc - fs*32;
        QRS = QRS - fs*32;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'32','33','34','35','36','37','38','39','40'});
        xlabel('Time (seconds)','Fontsize',12);
        
        
    elseif L>=40 && L < 48
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
               
        subplot(6,1,1);hold on;
        ecg = ecg1(1:8*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(find(loc1<8*fs));
        QRS = QRS1(find(QRS<8*fs));
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'0','1','2','3','4','5','6','7','8'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(6,1,2);hold on;
        ecg = ecg1(8*fs+1:16*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>8*fs),find(loc1<16*fs)));
        QRS = QRS1(intersect(find(QRS1>8*fs),find(QRS1<16*fs)));
        loc = loc - fs*8;
        QRS = QRS - fs*8;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'8','9','10','11','12','13','14','15','16'});
        xlabel('Time (seconds)','Fontsize',12);
                
        subplot(6,1,3);hold on;
        ecg = ecg1(16*fs+1:24*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>16*fs),find(loc1<24*fs)));
        QRS = QRS1(intersect(find(QRS1>16*fs),find(QRS1<24*fs)));
        loc = loc - fs*16;
        QRS = QRS - fs*16;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'16','17','18','19','20','21','22','23','24'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(6,1,4);hold on;
        ecg = ecg1(24*fs+1:32*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>24*fs),find(loc1<32*fs)));
        QRS = QRS1(intersect(find(QRS1>24*fs),find(QRS1<32*fs)));
        loc = loc - fs*24;
        QRS = QRS - fs*24;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'24','25','26','27','28','29','30','31','32'});
        xlabel('Time (seconds)','Fontsize',12);
                
        subplot(6,1,5);hold on;
        ecg = ecg1(32*fs+1:40*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>32*fs),find(loc1<40*fs)));
        QRS = QRS1(intersect(find(QRS1>32*fs),find(QRS1<40*fs)));
        loc = loc - fs*32;
        QRS = QRS - fs*32;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'32','33','34','35','36','37','38','39','40'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(6,1,6);hold on;
        ecg = ecg1(40*fs+1:end);
        plot(ecg);xlim([0 2400]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>40*fs),find(loc1<length(ecg1))));
        QRS = QRS1(intersect(find(QRS1>40*fs),find(QRS1<length(ecg1))));
        loc = loc - fs*40;
        QRS = QRS - fs*40;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'40','41','42','43','44','45','46','47','48'});
        xlabel('Time (seconds)','Fontsize',12);
               
    elseif L>=48 && L < 56
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
                
        subplot(7,1,1);hold on;
        ecg = ecg1(1:8*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(find(loc1<8*fs));
        QRS = QRS1(find(QRS<8*fs));
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'0','1','2','3','4','5','6','7','8'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(7,1,2);hold on;
        ecg = ecg1(8*fs+1:16*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>8*fs),find(loc1<16*fs)));
        QRS = QRS1(intersect(find(QRS1>8*fs),find(QRS1<16*fs)));
        loc = loc - fs*8;
        QRS = QRS - fs*8;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'8','9','10','11','12','13','14','15','16'});
        xlabel('Time (seconds)','Fontsize',12);
                
        subplot(7,1,3);hold on;
        ecg = ecg1(16*fs+1:24*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>16*fs),find(loc1<24*fs)));
        QRS = QRS1(intersect(find(QRS1>16*fs),find(QRS1<24*fs)));
        loc = loc - fs*16;
        QRS = QRS - fs*16;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'16','17','18','19','20','21','22','23','24'});
        xlabel('Time (seconds)','Fontsize',12);
               
        subplot(7,1,4);hold on;
        ecg = ecg1(24*fs+1:32*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>24*fs),find(loc1<32*fs)));
        QRS = QRS1(intersect(find(QRS1>24*fs),find(QRS1<32*fs)));
        loc = loc - fs*24;
        QRS = QRS - fs*24;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'24','25','26','27','28','29','30','31','32'});
        xlabel('Time (seconds)','Fontsize',12);
                
        subplot(7,1,5);hold on;
        ecg = ecg1(32*fs+1:40*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>32*fs),find(loc1<40*fs)));
        QRS = QRS1(intersect(find(QRS1>32*fs),find(QRS1<40*fs)));
        loc = loc - fs*32;
        QRS = QRS - fs*32;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'32','33','34','35','36','37','38','39','40'});
        xlabel('Time (seconds)','Fontsize',12);
               
        subplot(7,1,6);hold on;
        ecg = ecg1(40*fs+1:48*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>40*fs),find(loc1<48*fs)));
        QRS = QRS1(intersect(find(QRS1>40*fs),find(QRS1<48*fs)));
        loc = loc - fs*40;
        QRS = QRS - fs*40;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'40','41','42','43','44','45','46','47','48'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(7,1,7);hold on;
        ecg = ecg1(48*fs+1:end);
        plot(ecg);xlim([0 2400]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>48*fs),find(loc1<length(ecg1))));
        QRS = QRS1(intersect(find(QRS1>48*fs),find(QRS1<length(ecg1))));
        loc = loc - fs*48;
        QRS = QRS - fs*48;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'48','49','50','51','52','53','54','55','56'});
        xlabel('Time (seconds)','Fontsize',12);
                
    elseif L>=56 && L < 64
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        
        subplot(8,1,1);hold on;
        ecg = ecg1(1:8*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(find(loc1<8*fs));
        QRS = QRS1(find(QRS<8*fs));
        plot(loc,ecg(loc),'ro','MarkerSize',5,'Linewidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'Linewidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'0','1','2','3','4','5','6','7','8'});
        xlabel('Time (seconds)','Fontsize',12);
        
        subplot(8,1,2);hold on;
        ecg = ecg1(8*fs+1:16*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>8*fs),find(loc1<16*fs)));
        QRS = QRS1(intersect(find(QRS1>8*fs),find(QRS1<16*fs)));
        loc = loc - fs*8;
        QRS = QRS - fs*8;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'8','9','10','11','12','13','14','15','16'});
        xlabel('Time (seconds)','Fontsize',12);
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        subplot(8,1,3);hold on;
        ecg = ecg1(16*fs+1:24*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>16*fs),find(loc1<24*fs)));
        QRS = QRS1(intersect(find(QRS1>16*fs),find(QRS1<24*fs)));
        loc = loc - fs*16;
        QRS = QRS - fs*16;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'16','17','18','19','20','21','22','23','24'});
        xlabel('Time (seconds)','Fontsize',12);
        
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        subplot(8,1,4);hold on;
        ecg = ecg1(24*fs+1:32*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>24*fs),find(loc1<32*fs)));
        QRS = QRS1(intersect(find(QRS1>24*fs),find(QRS1<32*fs)));
        loc = loc - fs*24;
        QRS = QRS - fs*24;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'24','25','26','27','28','29','30','31','32'});
        xlabel('Time (seconds)','Fontsize',12);
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        subplot(8,1,5);hold on;
        ecg = ecg1(32*fs+1:40*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>32*fs),find(loc1<40*fs)));
        QRS = QRS1(intersect(find(QRS1>32*fs),find(QRS1<40*fs)));
        loc = loc - fs*32;
        QRS = QRS - fs*32;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'32','33','34','35','36','37','38','39','40'});
        xlabel('Time (seconds)','Fontsize',12);
        
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        subplot(8,1,6);hold on;
        ecg = ecg1(40*fs+1:48*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>40*fs),find(loc1<48*fs)));
        QRS = QRS1(intersect(find(QRS1>40*fs),find(QRS1<48*fs)));
        loc = loc - fs*40;
        QRS = QRS - fs*40;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'40','41','42','43','44','45','46','47','48'});
        xlabel('Time (seconds)','Fontsize',12);
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        subplot(8,1,7);hold on;
        ecg = ecg1(48*fs+1:56*fs);
        plot(ecg);xlim([0 length(ecg)]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>48*fs),find(loc1<56*fs)));
        QRS = QRS1(intersect(find(QRS1>48*fs),find(QRS1<56*fs)));
        loc = loc - fs*48;
        QRS = QRS - fs*48;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'48','49','50','51','52','53','54','55','56'});
        xlabel('Time (seconds)','Fontsize',12);
        
        loc = loc1;
        QRS = QRS1;
        ecg = ecg1;
        subplot(8,1,8);hold on;
        ecg = ecg1(56*fs+1:end);
        plot(ecg);xlim([0 2400]);grid on;grid minor;
        loc = loc1(intersect(find(loc1>56*fs),find(loc1<length(ecg1))));
        QRS = QRS1(intersect(find(QRS1>56*fs),find(QRS1<length(ecg1))));
        loc = loc - fs*56;
        QRS = QRS - fs*56;
        plot(loc,ecg(loc),'ro','MarkerSize',5,'LineWidth',1);%,'MarkerFaceColor','b');
        plot(QRS,ecg(QRS),'o','MarkerEdgeColor',[0,0.8,0],'LineWidth',1);
        L = get(gca,'XLim');
        set(gca,'XTick',linspace(L(1),L(2),9));
        xticklabels({'56','57','58','59','60','61','62','63','64'});
        xlabel('Time (seconds)','Fontsize',12);

end

end

end

