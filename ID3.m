
classdef ID3
     
    properties 
        translator;
        stats_data; 
        train_val;
        root;
        
    end
     
    methods
        %function ========================================================
        function obj = construct_tree(obj, training_set) 
                        
            obj.train_val = size(training_set,2);
             
            for i = 1 : size(training_set,2)  
                clear table;
                table = tabulate(training_set(:,i)); 
                cout = 1;
                for j = 1 : size(table,1) 
                    if table(j,2)   
                        stats_data{1,i}(1,cout) = table(j,1);
                        cout = cout + 1;
                    end
                end
            end
            obj.stats_data = stats_data;
            dim_visible = ones(1, size(training_set,2)-1);
             
            obj.root = make_tree(training_set,dim_visible,stats_data);
        end
         
        %function ========================================================
        function [cor_ration,targets] = classify(obj, testing_set)
            %
            if ~isempty(obj.translator)  % to translate the data
                trans_test = obj.translator.translate_test(testing_set);
                clear testing_set;
                testing_set = trans_test;
            end      
            train_set_dimension = obj.train_val;  
            classifier_tree = obj.root;
             
            targets = zeros(size(testing_set,1), 1);
            for i = 1: size(testing_set, 1)
                targets(i, 1) = class_classifier(classifier_tree, testing_set(i,1:train_set_dimension-1));
            end
             
            if train_set_dimension == size(testing_set, 2)  %same dimension, then get the correct ratio
                cout = 0;
                for i = 1: size(testing_set, 1)
                    if testing_set(i, end) == targets(i, 1)
                        cout = cout + 1;
                    end
                end
                cor_ration = cout / size(testing_set, 1);
            else
                cor_ration = -1; %not for testing the classifying Precision
            end
 
        end
         
    end
 
end
 
 
function tree = make_tree(training_set, dim_visible, stats_data)
%training_set is a numberic matrix with the class label at the last
%dimensiion
 
[trs_r, trs_c] = size(training_set);
Table = tabulate(training_set(:,end));
cout = 1;
for i = 1 : size(Table,1)
    if Table(i,2)
        unique_clss(cout, 1) = Table(i,1);
        unique_cls_perc(cout, 1) = Table(i, 3) / 100;
        cout = cout + 1;
    end
end
 
if size(unique_clss)==1      %all samples' class are same
    tree.name = unique_clss(1,1);
    tree.split_dim = 0;  %leaf
    tree.split_value = inf;
    tree.child = inf;
    return;
end
 
if zeros_validation(dim_visible)     %no attribute can be used for splitting   
    [max_num, max_index] = max(unique_cls_perc);
    tree.name = unique_clss(max_index, 1);
    tree.split_dim = 0;
    tree.split_value = inf;
    tree.child = inf;
    return;
end
 
I_expext_info = 0;
 
%get the expect information for classifying the samples.
for i = 1 : size(unique_clss, 1)
    I_expext_info = I_expext_info + (-1)*unique_cls_perc(i, 1) * log2(unique_cls_perc(i,1));
end
 
tree.name = inf;
great_info_gain = 0; 
tree.split_dim = 0; % dimension 
 
for i = 1 : size(dim_visible, 2)  %choose the attribute
    if dim_visible(1, i)       
        clear diff_cls;
        clear diff_value;
        diff_cls = stats_data{1, trs_c};
                
        diff_value = stats_data{1, i};
         
        value_class = zeros(length(diff_value), length(diff_cls));
         
        for j = 1 : size(training_set, 1)
            index_v = 0;
            index_c = 0;
            for k = 1 : size(diff_value, 2)
                if diff_value(1, k)==training_set(j, i)
                    index_v = k;
                    break;
                end
            end
             
            for t = 1 : size(diff_cls, 2)
                if diff_cls(1, t)==training_set(j, end)
                    index_c = t;
                   
                    break;
                end
            end
            if index_v && index_c
                value_class(index_v, index_c) = value_class(index_v, index_c) + 1;
            end
        end
         
        entrop_info = 0;
        sum_m_n = sum(sum(value_class));
 
        for m = 1 : size(diff_value, 2)
            sum_m = sum(value_class(m,:));
            if sum_m == 0
                continue;
            end
            expenct_info = 0;
            for n = 1 : size(diff_cls, 2)
                 p_m_n = value_class(m,n) / sum_m;
                  
                 if p_m_n ~= 0
                     expenct_info = expenct_info + (-1)* (p_m_n) * log2(p_m_n);
                 end
            end     
             
            prob = sum_m / sum_m_n;
            entrop_info = entrop_info + prob * expenct_info;
        end
         
        gain = I_expext_info - entrop_info;
         
        if gain > great_info_gain
            great_info_gain = gain;
            tree.split_dim = i;
            clear global_value_class
            global_value_class = value_class;
        end
         
    end
end
 
if tree.split_dim == 0 
     [max_num, max_index] = max(unique_cls_perc);
     tree.name = unique_clss(max_index, 1);
     tree.split_dim = 0;
     tree.split_value = inf;
     tree.child = inf;
     return;
end
 
dim_visible(1, tree.split_dim) = 0;
clear split_value;
split_value = stats_data{1, tree.split_dim};
tree.split_value = split_value;
 
dim = tree.split_dim;
 
for i = 1 : size(split_value, 2)  
    clear new_train_set;
    total = sum(global_value_class(i,:));
     
    if total 
        new_train_set = zeros(total, trs_c);
        cout = 1;
        for j = 1 : size(training_set, 1)
            if training_set(j, dim) == split_value(1, i)
                new_train_set(cout, :) = training_set(j, :);
                cout = cout + 1;
            end
        end
        tree.child(i) =  make_tree(new_train_set,dim_visible, stats_data);
 
    else
        [max_num, max_index] = max(unique_cls_perc);
        tree.child(i).name = unique_clss(max_index, 1);
        tree.child(i).split_dim = 0;
         tree.child(i).split_value = inf;
         tree.child(i).child = inf;
    end
 
end
 
end
 
 
function target = class_classifier(classifier_tree, test_tuple)
 
node = classifier_tree;
 
while node.split_dim   %split_dim==0 is a leaf    
    value = test_tuple(1, node.split_dim);
    for i = 1 : size(node.split_value, 2);
        if node.split_value(1, i)==value
            node = node.child(i);
            break;
        end
    end
end
target = node.name;
end
 
 
function yes = zeros_validation(vector)
%check whether all elements of vector are zeros
yes = 1;
for i = size(vector, 2): -1 : 1
    if vector(1,i)
        yes = 0;
        break;
    end
end
end
