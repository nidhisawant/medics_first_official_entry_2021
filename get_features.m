function [fbfeat, scattTrain] = get_features(data, header_data,leads_idx) %get_ECGLeads_features

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose: Extract features from ECG signals of every lead
% Inputs:
% 1. ECG data from available leads (data)
% 2. Header files including the number of leads (header_data)
% 3. The available leads index (in data/header file)
%
% Outputs:
% features for every ECG lead:
% 1. Age 2. Sex 3. root square mean (RSM) of the ECG leads
%
% Author: Nadi Sadr, PhD, <nadi.sadr@dbmi.emory.edu>
% Version 1.0
% Date 25-Nov-2020
% Version 2.1, 25-Jan-2021
% Version 2.2, 11-Feb-2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read number of leads, sample frequency and adc_gain from the header.
[recording,Total_time,num_leads,Fs,adc_gain,age,sex,Baseline] = extract_data_from_header(header_data);
num_leads = length(leads_idx);
sf = waveletScattering('SignalLength',5000,'SamplingFrequency',500);

try
    % ECG processing
    % Preprocessing
    for i = [leads_idx]
        % Apply adc_gain and remove baseline
        LeadswGain(i,:)   = (data(i,:)-Baseline(i))./adc_gain(i);
        
        filt_ecg(i,:)=BP_filter_ECG(LeadswGain(i,:),Fs);

        % Extract root square mean (RSM) feature
        %RSM(i) = sqrt(sum(LeadswGain(i,:).^2))./length(LeadswGain(i,:));       
       % features(jj) = RSM(i);
        
    end
    if Fs~=500
        for i=[leads_idx]
            res_ecg(i,:)=resample(filt_ecg(i,:),500,Fs);
        end
        Fs=500;
        ref_ecg=ecg_noisecancellation( res_ecg, Fs);
    else
        ref_ecg=ecg_noisecancellation( filt_ecg, Fs);
    end
    
    if (size(ref_ecg,2)>10*Fs-1)
        for kk=[leads_idx]
            data1(kk,:)=ref_ecg(kk,1:10*Fs);
        end
    else
        for kk=[leads_idx]
            data1(kk,:)=resample(ref_ecg(kk,:),10*Fs,length(ref_ecg(kk,:)));
        end
    end
    try
        qrs=qrs_detect2(normalize(data1(2,:)),0.25, 0.6, Fs);

    catch
        if Fs~=500
            res_data=resample(filt_ecg(2,:),500,Fs);
            Fs=500;
        else
            res_data= filt_ecg(2,:);
        end
        qrs=qrs_detect2(normalize(res_data),0.25, 0.6, Fs);
    end 
    if isempty(qrs) || length(qrs)<5
        fbfeat=zeros(1,20);
    else
    app=[];
    while(size(app,2)<20)
        app=[app qrs];
    end
    napp=app(1,[1:20]);
    fbfeat=fourierbessel(napp);
    end

   scattTrain=[];
    for kk=[leads_idx]
            sct_feat1= featureMatrix(sf,data1(kk,:))';
            sct_feat = feature_mean(sct_feat1);
            scattTrain=[scattTrain; sct_feat];
    end
    
   
    
catch
    features_length = num_leads;
    scattTrain=zeros(features_length,202);
    fbfeat=zeros(1,20);
end

% The last two features are age and sex from header file

end
