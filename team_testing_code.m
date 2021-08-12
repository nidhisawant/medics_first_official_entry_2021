%% Apply classifier model to test set

function [score, label,classes] = team_testing_code(data,header_data, loaded_model)

model   = loaded_model.model;
classes = loaded_model.classes;
load('mu_sg.mat');
num_classes = length(classes);
for j=1:size(classes,2)
    classes_double(j)=str2double(classes{j});
end
scored_labels=[164889003	164890007	6374002	426627000	733534002 164909002	713427006 59118001	270492004	713426002	39732003	445118002	164947007	251146004	111975006	698252002	426783006	284470004 63593006	10370003	365413008	427172004 17338001	164917005	47665007	427393009	426177001	427084000	164934002	59931005];
for j=1:size(scored_labels,2)
    scored_label_idx(j)=find(classes_double==scored_labels(j));
end
label = zeros([1,num_classes]);

score = zeros([1,num_classes]);

% Extract features from test data
tmp_hea = strsplit(header_data{1},' ');
num_leads = str2num(tmp_hea{2});
[leads, leads_idx] = get_leads(header_data,num_leads);
[fbfeat, scattTrain] = get_features(data, header_data,leads_idx);
scattTrain(isnan(scattTrain))=0;
scattTrain(isinf(scattTrain))=0;
scattTrain=(scattTrain-mu_sc(leads_idx,1))./sg_sc(leads_idx,1);
scattTrain(isnan(scattTrain))=0;
fbfeat(isnan(fbfeat))=0;
fbfeat(isinf(fbfeat))=0;
fbfeat=(fbfeat-mu_fb)./sg_fb;
Testd=[reshape(scattTrain,[1,(size(scattTrain,1)*size(scattTrain,2))]) fbfeat];
switch num_leads
    case 12
        miniBatchSize = 100;
    case 6
        miniBatchSize = 200;
    case 4
        miniBatchSize = 300;
    case 3
        miniBatchSize = 400;
    case 2
        miniBatchSize = 500;
    otherwise
end
dlYPredValidation2 = modelPredictions(model,Testd,miniBatchSize);
YPredValidation = extractdata(dlYPredValidation2) > labelThreshold;
label(scored_label_idx)=[YPredValidation(1:4,1)' YPredValidation(5,1)' YPredValidation(5,1)' YPredValidation(6,1)' YPredValidation(6,1)' YPredValidation(7:15,1)' YPredValidation(16,1)' YPredValidation(16,1)' YPredValidation(17:18,1)' YPredValidation(19,1)' YPredValidation(19,1)' YPredValidation(20:26,1)'];   
score(scored_label_idx)=[dlYPredValidation2(1:4,1)' dlYPredValidation2(5,1)' dlYPredValidation2(5,1)' dlYPredValidation2(6,1)' dlYPredValidation2(6,1)' dlYPredValidation2(7:15,1)' dlYPredValidation2(16,1)' dlYPredValidation2(16,1)' dlYPredValidation2(17:18,1)' dlYPredValidation2(19,1)' dlYPredValidation2(19,1)' dlYPredValidation2(20:26,1)'];

% Use your classifier here to obtain a label and score for each class.
%score = mnrval(model,features);
%[~,idx] = nanmax (score);

%label(idx)=1;
end
