function parameters= model_formation(fb_feat, scatt_feat_leads, label, classes)
sc_avg2 = cellfun(@(x) reshape(x,[1, (size(scatt_feat_leads{1},1)*size(scatt_feat_leads{1},2))]),scatt_feat_leads,'UniformOutput',false);

sc_avg3=cat(1,sc_avg2{:});
data=[sc_avg3 fb_feat];

%% Labels formation (from 133 to 26)
for j=1:size(classes,2)
    classes_double(j)=str2double(classes{j});
end
scored_labels=[164889003	164890007	6374002	426627000	733534002 164909002	713427006 59118001	270492004	713426002	39732003	445118002	164947007	251146004	111975006	698252002	426783006	284470004 63593006	10370003	365413008	427172004 17338001	164917005	47665007	427393009	426177001	427084000	164934002	59931005];
for j=1:size(scored_labels,2)
    scored_label_idx(j)=find(classes_double==scored_labels(j));
end
new_label=[];
for j=1:size(scored_labels,2)
    vec=label(:,scored_label_idx(j));
    new_label=[new_label vec];
end
clbbb=new_label(:,5) + new_label(:,6);
rbbb=new_label(:,7) + new_label(:,8);
pac=new_label(:,18) + new_label(:,19);
pvc=new_label(:,22) + new_label(:,23);
clbbb(clbbb>1)=1;
rbbb(rbbb>1)=1;
pac(pac>1)=1;
pvc(pvc>1)=1;
labels=[new_label(:,1:4) clbbb rbbb new_label(:,9:17) pac new_label(:,20:21) pvc new_label(:,24:30)];

n=7000;
for i=1:26
    idx=find(labels(:,i)==1);
    if isempty(idx)
        continue;
    else
        idx2=find(labels(:,i)==0);
        data2=data(idx,:);
        rest_data2=data(idx2,:);
        lab=labels(idx,:);
        rest_lab=labels(idx2,:);
        if length(idx)<n
            while size(data2,1)<n
                data2=[data2; data2];
                lab=[lab; lab];
            end
            r1=randperm(size(data2,1),n);
            n_data2=data2(r1,:);
            n_lab=lab(r1,:);
            data=[rest_data2; n_data2];
            labels=[rest_lab; n_lab];
        else
            r1=randperm(length(data2),n);
            n_data2=data2(r1,:);
            n_lab=lab(r1,:);
            data=[rest_data2; n_data2];
            labels=[rest_lab; n_lab];
        end
    end
end


X1=data;
numFeatures = size(X1,2);
numObservations = size(X1,1);
sequenceLength = 1;
numClasses=size(labels,2);

numHiddenUnits = 100;
H0 = zeros(numHiddenUnits,1);

parameters = struct;
parameters.gru.InputWeights = dlarray(initializeGlorot(3*numHiddenUnits,sequenceLength));
parameters.gru.RecurrentWeights = dlarray(initializeGlorot(3*numHiddenUnits,numHiddenUnits));
parameters.gru.Bias = dlarray(zeros(3*numHiddenUnits,1,'single'));

parameters.fc.Weights = dlarray(initializeGaussian([numClasses,numHiddenUnits]));
parameters.fc.Bias = dlarray(zeros(numClasses,1,'single'));


numEpochs = 70;

switch size(scatt_feat_leads{1},1)
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

learnRate = 0.01;
gradientDecayFactor = 0.5;
squaredGradientDecayFactor = 0.999;

gradientThreshold = 1;



labelThreshold = 0.4;

cvp = cvpartition(size(X1,1),'HoldOut',0.2);
dataTrain = X1(training(cvp),:,:);
dataValidation = X1(test(cvp),:,:);

labelsTrain = labels(training(cvp),:);
labelsValidation = labels(test(cvp),:);

numObservationsTrain = size(dataTrain,1);
numIterationsPerEpoch = floor(numObservationsTrain/miniBatchSize);
validationFrequency = numIterationsPerEpoch;

executionEnvironment = "auto";


trailingAvg = [];
trailingAvgSq = [];

numObservationsValidation = size(dataValidation,1);
TValidation = labelsValidation';

iteration = 0;
start = tic;

% Loop over epochs.
for epoch = 1:numEpochs
    
    % Loop over mini-batches.
    for i = 1:numIterationsPerEpoch
        iteration = iteration + 1;
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        
        % Read mini-batch of data and convert the labels to dummy
        % variables.
        X = dataTrain(idx,:,:);
        T = labelsTrain(idx,:)';
        
        % Convert documents to sequences.
        
        
        % Dummify labels.
        
        
        % Convert mini-batch of data to dlarray.
        dlX = dlarray(X,'BTC');
        
        % If training on a GPU, then convert data to gpuArray.
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
            dlX = gpuArray(dlX);
        end
        
        % Evaluate the model gradients, state, and loss using dlfeval and the
        % modelGradients function.
        [gradients,loss,dlYPred] = dlfeval(@modelGradients, dlX, T, parameters);
        
        % Gradient clipping.
        gradients = dlupdate(@(g) thresholdL2Norm(g, gradientThreshold),gradients);
        
        % Update the network parameters using the Adam optimizer.
        [parameters,trailingAvg,trailingAvgSq] = adamupdate(parameters,gradients, ...
            trailingAvg,trailingAvgSq,iteration,learnRate,gradientDecayFactor,squaredGradientDecayFactor);
        
        
    end
    
    % Shuffle data.
    idx = randperm(numObservationsTrain);
    dataTrain = dataTrain((idx),:,:);
    labelsTrain = labelsTrain(idx,:);
    
end


end

