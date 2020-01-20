%#####################################################################
% Group : Singh_Venkatachalam_Balakrishnan
% Students names : 1) Barathadhithya Balakrishnan Sundaramoorthy 
%                  2) Sree Naveen Venkatachalam 
%                  3) Rohit Pal Singh      
% M# : 1) M13506318
%      2) M13450780
%      3) M13256478 
%#####################################################################
%##                        Machine Learning Assignment1             ##
%##                        Implementing ID3                         ##
%#####################################################################


%#####################################################################
%   We use the following classes
%   1) DataHolder       /a class to hold training and testing data
%   2) DataStore        /a class to load data and make values discrete
%   
%   3) ID3              /a class that implements the Decision tree
%                           algorithm 
%   4) Constants        /a class that define constants values related to
%                           the data
%#####################################################################

%instantiate a new instance of the DataStore class
DM1 = DataStore();
%load the data
DM1.LoadData();

%indices for the avg accuracies
AVG_ACCURACY = 1;

AccuraciesTree = zeros(4, 3);
    
    % Running time for each bin
    RunningTime = 10;
    
    prompt = 'Please enter the discretization method CACC - 0, NAIVE - 1  ->';
    x = input(prompt);
    
    %run different combination of training and test data for 10 times 
    
    for i=1:RunningTime
       
        %get a new instance of an object from class DataHolder, with data
        %already loaded into it using a function from the data manager
        %class
        DH1 = DM1.readyDataEnhanced(x);
        %insantiate a new instance from the class decision tree (ID3)
        DT1 = ID3();
        %train tree
        DT1 = DT1.construct_tree(DH1.Data_Training);
        
        %in ResultsTree the accuracy will be returned  
        [ResultsTree, targets] = DT1.classify(DH1.Data_Testing);

        %Resultstree out of 100
        ResultsTree = ResultsTree*100;
        
        
        %store accuracy in vector
        AccuraciesTree(i, AVG_ACCURACY) = mean(ResultsTree); 
    end
    

hFig = figure('Name', 'accuracies at 10 runs');
set(hFig, 'Position', [30 15 120 80]);

% tree results
% subplot(1,1,10);
TreePlotHandle = plot(1:1:10, AccuraciesTree(:, AVG_ACCURACY), '-rs');
title('Tree Avg accuracies at 10 runs');
legend({'Accuracy'}, ...
        'Position', [0.4, 0.65, 0, 0]);
ylim([85 105]);
ylabel('Accuracy');
xlabel('Number of Runs');


