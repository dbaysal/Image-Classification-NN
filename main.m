
% 
% outputSize = [350 350];
% 
% 
% 
% cloudy = dir('Dataset/cloudy*.jpg');
% shine = dir('Dataset/shine*.jpg');
% sunrise = dir('Dataset/sunrise*.jpg');
% cloudy_lab = repmat({'cloudy'},numel(cloudy),1);
% shine_lab = repmat({'shine'},numel(shine),1);
% sunrise_lab = repmat({'sunrise'},numel(sunrise),1);
% 
% labs = [cloudy_lab; shine_lab; sunrise_lab];
% imds = imageDatastore({'Dataset/cloudy*.jpg' 'Dataset/shine*.jpg' 'Dataset/sunrise*.jpg'},'Labels',categorical(labs));
% [trainds,testds,valds] = splitEachLabel(imds,.6,.2);
% 
% 
% 
% 
% 
% augmenter = imageDataAugmenter( ...
%     'RandRotation',[0 360], ...
%     'RandScale',[0.5 1], ...
%     'RandRotation',[-20,20], ...
%     'RandXTranslation',[-3 3], ...
%     'RandYTranslation',[-3 3]);
% 
% auimds_train = augmentedImageDatastore(outputSize,trainds,'ColorPreprocessing','rgb2gray');
% auimds_val = augmentedImageDatastore(outputSize,valds,'ColorPreprocessing','rgb2gray');
% 
% 
% 
% 
% 
% 
% 
% 
% maxEpochs = 50;
% miniBatchSize = 128;
% numObservations = (900*70/100);
% numIterationsPerEpoch = floor(numObservations / miniBatchSize);
% 
% layers1 = [ ...  %1 hidden layer
%     imageInputLayer([350 350 1],"Normalization","zerocenter","NormalizationDimension","all")
%     fullyConnectedLayer(100,'WeightsInitializer','glorot','BiasInitializer','narrow-normal')
%     batchNormalizationLayer
%     reluLayer
%     fullyConnectedLayer(3)
%     softmaxLayer
%     classificationLayer];
% 
% layers2 = [ ...  %2 hidden layers
%     imageInputLayer([350 350 1],"Normalization","zerocenter","NormalizationDimension","all")
%     fullyConnectedLayer(100,'WeightsInitializer','glorot','BiasInitializer','narrow-normal')
%     batchNormalizationLayer
%     reluLayer
%     fullyConnectedLayer(100,'WeightsInitializer','glorot','BiasInitializer','narrow-normal')
%     batchNormalizationLayer
%     reluLayer
%     fullyConnectedLayer(3)
%     softmaxLayer
%     classificationLayer];
% 
% layers3 = [ ...   % 3 hidden layers
%     imageInputLayer([350 350 1],"Normalization","zerocenter","NormalizationDimension","all")
%     fullyConnectedLayer(100,'WeightsInitializer','glorot','BiasInitializer','narrow-normal')
%     batchNormalizationLayer
%     reluLayer
%      fullyConnectedLayer(100,'WeightsInitializer','glorot','BiasInitializer','narrow-normal')
%     batchNormalizationLayer
%     reluLayer
%      fullyConnectedLayer(100,'WeightsInitializer','glorot','BiasInitializer','narrow-normal')
%     batchNormalizationLayer
%     reluLayer
%     fullyConnectedLayer(3)
%     softmaxLayer
%     classificationLayer];
% 
% options = trainingOptions('rmsprop',... 
%     'MaxEpochs',maxEpochs,...
%     'ValidationData',auimds_val,...
%     'InitialLearnRate',1e-5,...
%     'ValidationFrequency',numIterationsPerEpoch, ...
%     'MiniBatchSize',miniBatchSize, ...
%     'Verbose',false,...
%     'Plots','none');
% 
% 
% [net1,info1]=trainNetwork(auimds_train,layers1,options);
% [net2,info2]=trainNetwork(auimds_train,layers2,options);
% [net3,info3]=trainNetwork(auimds_train,layers3,options);
% 
% auimds_test = augmentedImageDatastore(outputSize,testds,'ColorPreprocessing','rgb2gray');
% 

load("params.mat");

max=info1.FinalValidationAccuracy;
information=[info2.FinalValidationAccuracy,info3.FinalValidationAccuracy];
check=1;

for i=1:length(information)
    if information(i)>max
        max=information(i);
        check=i+1;
    end
end



fprintf("Best Final Validation accuracy is for %d hidden layers : %.4f\n",check,max);


%as net objects takes too much space and I can't upload my parameters file
%to odtuclass I will delete net1 and net3 as I know only net2 will be used
%(best configuration)

if check==1
    YPred = classify(net1,auimds_test);
    YTest = testds.Labels;
    accuracy = sum(YPred == YTest)/numel(YTest);

elseif check==2
    YPred = classify(net2,auimds_test);
    YTest = testds.Labels;
    accuracy = sum(YPred == YTest)/numel(YTest);

else
    YPred = classify(net3,auimds_test);
    YTest = testds.Labels;
    accuracy = sum(YPred == YTest)/numel(YTest);
end


fprintf("Accuracy using test set for %d hidden layer : %.4f\n",check,accuracy*100);
fprintf("Error rate : %.4f ",100-(accuracy*100))


%Best accuracy for validation is with 2 hidden layers in my case. This is
%most probably because my data set is not complex enough to fit 3 hidden layer
%structure but also it is more complex to fit into 1 hidden layer as well.
%with different hyperparameters I get different results in different
%layers. When I made my architecture complex enough I got higher accuracy in
%3 hidden layers.


%As training set is really small, to decrease overfitting I tried to
%increase training set (By increasing it from 50% of total images to 60%).
%As training set was still not big enough I increased epochs to 50 to
%increase iterations. Also I increased mini batch size too and started to get better
%validation accuracy. I tried different weight and bias initializers but
%got the best result with the combination of glorot and narrow-normal initializers. First I
%tried to use 1e-4 Learning rate but I got NaN values for validation
%accuracy so I changed it to 1e-5. Also my architecture was over complex
%and to decrease overfitting I decreased output size of layers to 100.
%Lastly I tried tanh, leakyRelu, Relu activation layers but got the best
%results with Relu.




