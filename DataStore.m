classdef DataStore<handle
    %manage data loading and partitioning
    
    properties (Access = private)
        
        setosa_data;
        versicolor_data;
        virginica_data;
        
        setosa_discrete;
        versicolor_discrete;
        virginica_discrete;
    end
    
    methods
        %constructor
        function obj = DataStore()
        %defining with null
        end
       
        %function to load the data
        function LoadData(obj)
            
            load ('-ascii','iris.txt');
           
 
            %combine into one matrix
            merged_data = horzcat(iris);   
 
            %Split data into seperate sets according to species type to select training
            %data later from each species seperately (50% for training and 50% for testing)
            obj.setosa_data = merged_data(1:50,:);
            obj.versicolor_data = merged_data(51:100,:);
            obj.virginica_data = merged_data(101:150,:);
            
        end     %end of LoadData function
     
        %this function uses less loops
        function Data = readyDataEnhanced(obj, naive_cacc)
            
            if nargin < 2
                k_value = 3;
            end
            
            %split the data into training and testing sets
            setosa_r = randperm(50);
            versicolor_r = randperm(50);
            virginica_r = randperm(50);
            
            training_data = vertcat(obj.setosa_data(setosa_r(1:25),:), ...
                obj.versicolor_data(versicolor_r(1:25),:), ...
                obj.virginica_data(virginica_r(1:25),:));
            
            testing_data = vertcat(obj.setosa_data(setosa_r(26:50),:), ...
                obj.versicolor_data(versicolor_r(26:50),:), ...
                obj.virginica_data(virginica_r(26:50),:));
 
            %shuffle the testing data
            testing_data_randomized = testing_data(randperm(75), :);
            testing_data = testing_data_randomized;
            training_data_randomized = training_data(randperm(75), :);
            training_data = training_data_randomized;
            
   
            
            
            %convert the continous data to discrete values based on the
            %input provided by user 0 for cacc and 1 for naive
            
            if(naive_cacc == 0)
                % returns the discretized data
                [ disctrain_data,disctrain_values,disctrain_scheme ] = cacc(training_data);
                [ disctest_data,disctest_values,disctest_scheme ] = cacc(testing_data);
            else
                % calculate the discretized data for training using floor(next smaller integer)
                % method
                for i=1:length(training_data)
                training_data(:,Constants.SEPAL_LENGTH) = floor(training_data(:,Constants.SEPAL_LENGTH));
                training_data(:,Constants.SEPAL_WIDTH) = floor(training_data(:,Constants.SEPAL_WIDTH));
                training_data(:,Constants.PETAL_LENGTH) = floor(training_data(:,Constants.PETAL_LENGTH));
                training_data(:,Constants.PETAL_WIDTH) = floor(training_data(:,Constants.PETAL_WIDTH));
                disctrain_data = training_data;
                end
                % calculate the discretized data for testing using floor(next smaller integer)
                % method
                for i=1:length(testing_data)
                testing_data(:,Constants.SEPAL_LENGTH) = floor(testing_data(:,Constants.SEPAL_LENGTH));
                testing_data(:,Constants.SEPAL_WIDTH) = floor(testing_data(:,Constants.SEPAL_WIDTH));
                testing_data(:,Constants.PETAL_LENGTH) = floor(testing_data(:,Constants.PETAL_LENGTH));
                testing_data(:,Constants.PETAL_WIDTH) = floor(testing_data(:,Constants.PETAL_WIDTH));
                disctest_data = testing_data;
                end
            end
            Data = DataHolder();
            Data.Data_Training = disctrain_data;
            Data.Data_Testing = disctest_data;
        end
        
    end     %end of methods
end     %end of class
 


