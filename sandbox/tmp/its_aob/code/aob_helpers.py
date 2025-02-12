import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import sklearn
import random
import itertools
from sklearn.feature_selection import f_regression
from sklearn.feature_selection import r_regression
from sklearn.linear_model import LinearRegression
from sklearn.inspection import permutation_importance
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.neural_network import MLPRegressor
from sklearn.metrics import mean_absolute_error
from sklearn.metrics import mean_absolute_percentage_error
from sklearn.metrics import mean_squared_error
from enum import Enum
from IPython.display import display_html
from itertools import chain,cycle

def display_side_by_side(*args,titles=cycle([''])):
    html_str=''
    for df,title in zip(args, chain(titles,cycle(['</br>'])) ):
        html_str+='<th style="text-align:center"><td style="vertical-align:top">'
        html_str+=f'<h2 style="text-align: left;">{title}</h2>'
        html_str+=df.to_html().replace('table','table style="display:inline"')
        html_str+='</td></th>'
    display_html(html_str,raw=True)

def correlate_variables(df_input, param_1, param_2, threshold=0, is_graph=False):
    curr_corr = round(df_input[param_1].corr(df_input[param_2]),3)
    if is_graph:
        ax = sns.regplot(x = param_1, y = param_2, data = df_input, scatter_kws = {"color": "black", "alpha": 0.5}, line_kws = {"color": "red"})
        ax.set(xlabel=" ", ylabel=" ")
        plt.show()
        
    if abs(curr_corr) > threshold:
        print('Correlation between %s and %s is : %s' % (param_1, param_2, curr_corr))
    
    return curr_corr

class Algorithm(Enum):
    NEURAL_NETWORK = 1
    GRADIENT_BOOSTING = 2

def train_test_report_k_times(df_current, feature_name, label_name, hidden_s=(60,100,70), batch_size=1000, loss_draw=False, 
                              full_report=True, al=0.01, algorithm: Algorithm=Algorithm.NEURAL_NETWORK, shuffle=True, standardize=False, 
                              is_verbose=True, return_err=False, k=1):
    """
    Trains a model on the given dataset and evaluates its performance on a test set
    Draws loss graph on training and validations datasets

    Args:
        df_current (pandas.DataFrame): The input dataset
        feature_name (str): List of the feature column names
        label_name (str): Name of the target label column
        hidden_s (tuple, optional): Tuple specifying the hidden layer sizes for the neural network
        batch_size (int, optional): Batch size for training
        loss_draw (bool, optional): Whether to draw train and validation loss during training
        full_report (bool, optional): Whether to print a full performance report
        al (float, optional): Learning rate for the algorithm
        algorithm (Algorithm, optional): The machine learning algorithm to use (e.g., neural network)
        shuffle (bool, optional): Whether to shuffle the dataset
        standardize (bool, optional): Whether to standardize the features
        is_verbose(bool, optional): Whether to print information
        return_err(bool, optional): Whether to return error values
        k (int, optional): Number of times to run model and calculate performance metrics

    Returns:
        Tuple: Containing average (MAE, MAPE, MSE, RMSE) performance metrics
    """
    
    total_mae = 0
    total_mape = 0
    total_mse = 0
    total_rmse = 0
    for i in range(k):
        # override loss_draw; full_report; is_verbose; return_err
        a,b,c,d = train_test_report(df_current, feature_name, label_name, hidden_s=hidden_s, batch_size=batch_size, loss_draw=False, 
                                    full_report=True, al=al, algorithm=algorithm, shuffle=shuffle, standardize=standardize, 
                                    is_verbose=False, return_err=True)
        total_mae += a
        total_mape += b
        total_mse += c
        total_rmse += d

    if is_verbose:
        print("K: %s" % k)
        print("Average MAE: %s" % round(total_mae/k, 3))
        print("Average MAPE: %s" % round(total_mape/k, 3))
        print("Average MSE: %s" % round(total_mse/k, 3))
        print("Average RMSE: %s" % round(total_rmse/k, 3))
    
    if return_err:
        return (total_mae/k, total_mape/k, total_mse/k, total_rmse/k)

def train_test_report(df_current, feature_name, label_name, hidden_s=(60,100,70), batch_size=1000, loss_draw=False, 
                      full_report=True, al=0.01, algorithm: Algorithm=Algorithm.NEURAL_NETWORK, shuffle=False, standardize=False, 
                      is_verbose=False, return_err=False, return_model=False, return_fi=False):
    
    # statistics for scoring
    labels_std = df_current[label_name].describe()['std']
    labels_mean = df_current[label_name].describe()['mean']
    absolute_labels_mean = df_current[label_name].apply(abs).describe()['mean']
    
    # suhffle dataset
    if shuffle:
        df_current = df_current.sample(frac=1)
    
    # creating CN2 prediction model for d1
    features = df_current[feature_name]
    labels = df_current[label_name]
    
    # train test split
    data_train, data_test, labels_train, labels_test = train_test_split(features, labels, random_state=1, test_size=0.2)
    if is_verbose:
        print("Mean: %s; Absolute: %s" % (round(labels_mean, 3), round(absolute_labels_mean, 3)))
        print("Standart Deviation: %s" % round(labels_std, 3))
        print("\nTraining + Validation: %s; Test: %s" % (data_train[feature_name[0]].count(), data_test[feature_name[0]].count()))

    # standardize
    if standardize:
        sc_X = StandardScaler()
        data_train = sc_X.fit_transform(data_train)
        data_test = sc_X.transform(data_test)

    # draw train, validation loss
    # batch by batch for plotting
    if loss_draw:
        train_and_return_draw(data_train, labels_train, hidden_s, batch_size, al, is_verbose)
        
    if full_report:
        # train
        current_model = train_and_return(data_train, labels_train, hidden_s, al, algorithm)

        # predict
        labels_predicted = current_model.predict(data_test)
        
        # performance metrics
        mea = mean_absolute_error(labels_test, labels_predicted)
        mape = mean_absolute_percentage_error(labels_test, labels_predicted)
        mse = mean_squared_error(labels_test, labels_predicted)
        rmse = mean_squared_error(labels_test, labels_predicted, squared=False)
        # r2 = current_model.score(data_test, labels_test)
        # r2_train = current_model.score(data_train, labels_train)

        # report performance
        if is_verbose:
            # print("R2 Training score: %s" % round(r2_train, 3))
            # print("R2: %s" % round(r2, 3))
            print("MAE: %s" % round(mea, 3))
            print("MAPE: %s" % round(mape,3))
            print("MSE: %s" % round(mse,3))
            print("RMSE: %s" % round(rmse,3))
            print("\n")
    
        # return the model
        if return_err:
            return (mea, mape, mse, rmse)
        elif return_model:
            return current_model
        elif return_fi:
            return permutation_importance(current_model, data_test, labels_test, n_repeats=10)

def train_test_report_baseline(df_current, feature_name, label_name, shuffle=False):

    # suhffle dataset
    if shuffle:
        df_current = df_current.sample(frac=1)
    
    # creating CN2 prediction model for d1
    features = df_current[feature_name]
    labels = df_current[label_name]
    
    # train test split
    data_train, data_test, labels_train, labels_test = train_test_split(features, labels, random_state=1, test_size=0.2)

    # generating baseline label values
    test_labels_len = len(labels_test)
    '''
    labels_std = labels_train.apply(abs).describe()['std']
    labels_mean = labels_train.apply(abs).describe()['mean']
    labels_baseline_list = []
    for i in range(test_labels_len):
        # labels_baseline_list.append([labels_mean + (labels_std * random.random() * random.choice([1, -1]))])
        labels_baseline_list.append([labels_mean * random.choice([1, -1])])
    
    # labels_baseline_list = [labels_mean] * test_labels_len
    '''
    labels_baseline_list = [0.0] * test_labels_len
    
    baseline_mae =  mean_absolute_error(labels_test, labels_baseline_list)
    baseline_mape = mean_absolute_percentage_error(labels_test, labels_baseline_list)
    baseline_mse = mean_squared_error(labels_test, labels_baseline_list)
    baseline_rmse = mean_squared_error(labels_test, labels_baseline_list, squared=False)

    print("Baseline MAE: %s" % round(baseline_mae, 3))
    print("Baseline MAPE: %s" % round(baseline_mape,3))
    print("Baseline MSE: %s" % round(baseline_mse,3))
    print("Baseline RMSE: %s\n" % round(baseline_rmse,3))

def train_and_return_draw(features, labels, hidden_s, batch_size, al, is_verbose):
    
    # split validation
    X_train, X_valid, y_train, y_valid = train_test_split(features, labels, train_size=.8)
    
    # define regressor
    reg = MLPRegressor(hidden_layer_sizes=hidden_s, alpha=al)
    
    # calculate train and validation loss
    train_loss_, valid_loss_ = [], []
    if is_verbose:
        print("Training: %s; Validation: %s; Batch: %s\n" % (len(X_train), len(X_valid), batch_size))
    
    for _ in range(1):
        for b in range(batch_size, len(y_train), batch_size):
            X_batch, y_batch = X_train[b-batch_size:b], y_train[b-batch_size:b]
            reg.partial_fit(X_batch, y_batch)
            train_loss_.append(reg.loss_)
            # train_loss_.append(mean_squared_error(y_train, reg.predict(X_train)))
            valid_loss_.append(mean_squared_error(y_valid, reg.predict(X_valid)))

    plt.plot(range(len(train_loss_)), train_loss_, label="train loss")
    plt.plot(range(len(train_loss_)), valid_loss_, label="validation loss")
    plt.grid()
    # plt.yticks(np.arange(int(min(train_loss_)), int(max(valid_loss_)), 1.0))
    plt.legend
    plt.title('Training and Vaidation Loss')
    # plt.show()
    
    return reg

def train_and_return(features, labels, hidden_s, al, algorithm: Algorithm):
    
    if algorithm == Algorithm.NEURAL_NETWORK:
        reg = MLPRegressor(hidden_layer_sizes=hidden_s, max_iter=1000, verbose=0, random_state=1, alpha=al)
        reg.fit(features, labels.values.ravel())
        return reg
    elif algorithm == Algorithm.GRADIENT_BOOSTING:
        reg = GradientBoostingRegressor(random_state=0)
        reg.fit(features, labels.values.ravel())
        return reg