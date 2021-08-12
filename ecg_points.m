function [ P_index, Q_index, R_index, S_index, T_index] = ecg_points( ecg, fs )

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

P_index = [];
Q_index = [];
R_index = [];
S_index = [];
T_index = [];
out = [];
ecg_f = ecg;

if length(ecg) < 400
    return
end

[R_index,sign,en_thres,bpfecg,Q,S] = qrs_detect3(ecg',0.25,0.6,fs);

%% P wave detection
[out P_index] = Pwave( ecg, fs );

%% Invert ECG if necessary
amp = ecg(R_index);
if mean(amp) < 0 && median(amp) < 0
    ecg = -ecg;
end

%% Find RR Interval 
RR = diff(R_index')/fs;
if length(R_index) < 6
    R_index = [];
    return
end

%% P, Q, S, T Detection
ecg_f = filter_ecg( ecg, fs );

% Detect Q and S and T waves
for i = 1 : length(R_index)
    
    % S and T detection
    if i == length(R_index)
        temp = ecg_f(R_index(i)+1:length(ecg_f));
        [xymax,smax,xymin,smin] = extrema(temp);
        smax = smax + R_index(i);
        smin = smin + R_index(i);
        smax = smax(find(smax <= R_index(i)+round(0.6*(length(ecg_f)-R_index(i)))));
        smin = smin(find(smin <= R_index(i)+round(0.6*(length(ecg_f)-R_index(i)))));
    else
        temp = ecg_f(R_index(i)+1:R_index(i+1));
        [xymax,smax,xymin,smin] = extrema(temp);
        smax = smax + R_index(i);
        smin = smin + R_index(i);
        smax = smax(find(smax <= R_index(i)+round(0.6*(R_index(i+1)-R_index(i)))));
        smin = smin(find(smin <= R_index(i)+round(0.6*(R_index(i+1)-R_index(i)))));
    end
    
    if isempty(smin)
        if R_index(i) == length(ecg_f)
            S_index(i) = R_index(i);
        else
            S_index(i) = R_index(i) + 1;
        end
    elseif length(smin) == 1
        S_index(i) = smin(1);
    else
        if i == length(R_index)
            smin(find(smin > R_index(i)+round(0.3*(length(ecg_f)-R_index(i))))) = [];
        else
            smin(find(smin > R_index(i)+round(0.3*(R_index(i+1)-R_index(i))))) = [];
        end
        if length(smin) == 1
            S_index(i) = smin(1);
        elseif isempty(smin)
            if R_index(i) == length(ecg_f)
                S_index(i) = R_index(i);
            else
                S_index(i) = R_index(i) + 1;
            end
        else
            for j = 1 : length(smin)
                diffsmin(j) = abs(ecg_f(smin(j)) - ecg_f(R_index(i)));
            end
            [maxval maxind] = max(diffsmin);
            S_index(i) = smin(maxind);
        end
    end
    clear ind
    
    smax(find(smax < S_index(i))) = [];
    if isempty(smax)
        if S_index(i) == length(ecg_f)
            T_index(i) = S_index(i);
        else
            T_index(i) = S_index(i) + 1;
        end
    elseif length(smax) == 1
        T_index(i) = smax(1);
    else
        for j = 1 : length(smax)
            diffsmax(j) = abs(ecg_f(smax(j)) - ecg_f(S_index(i)));
        end
        [maxval maxind] = max(diffsmax);
        T_index(i) = smax(maxind);
    end

%     sall = sort([smax; smin]);
%     if length(sall) == 1 || isempty(sall)
%         
%         if R_index(i) == length(ecg_f)
%             S_index(i) = R_index(i);
%         else
%             S_index(i) = R_index(i) + 1;
%         end
%         
%         if S_index(i) == length(ecg_f)
%             T_index(i) = S_index(i);
%         else
%             T_index(i) = S_index(i) + 1;
%         end
%         
%     else
%         for j = 2 : length(sall)
%             diffs(j-1) = abs(ecg_f(sall(j)) - ecg_f(sall(j-1)));
%         end
%         [sorted_diffs, ind] = sort(diffs,'descend');
%         if isempty(ind)
%             if R_index(i) == length(ecg_f)
%                 S_index(i) = R_index(i);
%             else
%                 S_index(i) = R_index(i) + 1;
%             end
%             
%             if S_index(i) == length(ecg_f)
%                 T_index(i) = S_index(i);
%             else
%                 T_index(i) = S_index(i) + 1;
%             end
%         else
%             S_index(i) = sall(ind(1) + 1);
%             sall(find(sall<=S_index(i))) = [];
%             
%             if length(ind) == 1 || isempty(sall)
%                 if S_index(i) == length(ecg_f)
%                     T_index(i) = S_index(i);
%                 else
%                     T_index(i) = S_index(i) + 1;
%                 end
%             else
%                 new_diff = abs(ecg_f(sall) - ecg_f(S_index(i)));
%                 [maxval maxpos] = max(new_diff);
%                 T_index(i) = sall(maxpos);
%             end
%         end
%     end
        
    %Q detection
    if i == 1
        temp1 = ecg_f(1:R_index(i));
        [xymax1,smax1,xymin1,smin1] = extrema(temp1);
        smax1 = smax1(find(smax1 > round(0.8*(R_index(i)-1))));
        smin1 = smin1(find(smin1 > round(0.8*(R_index(i)-1))));
    else
        temp1 = ecg_f(R_index(i-1)+1:R_index(i));
        [xymax1,smax1,xymin1,smin1] = extrema(temp1);
        smax1 = smax1 + R_index(i-1);
        smin1 = smin1 + R_index(i-1);
        smax1 = smax1(find(smax1 > R_index(i-1) + round(0.8*(R_index(i)-R_index(i-1)))));
        smin1 = smin1(find(smin1 > R_index(i-1) + round(0.8*(R_index(i)-R_index(i-1)))));
    end
    sall1 = sort([smax1; smin1]);
    if length(sall1) == 1 
        Q_index(i) = sall1(1);
    elseif isempty(sall1)
        if R_index(i) == 1
            Q_index(i) = R_index(i);
        else
            Q_index(i) = R_index(i) - 1;
        end
    else
        for j = 2 : length(sall1)
            diffs1(j-1) = abs(ecg_f(sall1(j)) - ecg_f(sall1(j-1)));
        end
        [sorted_diffs1, ind1] = sort(diffs1,'descend');
        if isempty(ind1)
            Q_index(i) = R_index(i) - 1;
        else
            Q_index(i) = sall1(ind1(1));
        end
    end
 
    clear temp smax smin smax1 smin1 sall sall1 diffs diffs1 val req sorted_diffs sorted_diffs1 ind ind1 diffsmin sorted_diffsmin diffsmax sorted_diffsmax
end

end

