function dlYPred = modelPredictions(parameters,documents,miniBatchSize)


%numObservations = size(documents,2);
numObservations = size(documents,1);
numIterations = ceil(numObservations / miniBatchSize);

numFeatures = size(parameters.fc.Weights,1);
dlYPred = zeros(numFeatures,numObservations,'like',parameters.fc.Weights);

for i = 1:numIterations
    
    idx = (i-1)*miniBatchSize+1:min(i*miniBatchSize,numObservations);
    
    %X = documents(:,idx,:);
    X = documents(idx,:,:);
    
    %dlX = dlarray(X,'CBT');
    dlX = dlarray(X,'BTC');
    
    dlYPred(:,idx) = model(dlX,parameters);
end

end