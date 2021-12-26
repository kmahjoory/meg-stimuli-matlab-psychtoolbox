% function [gamma theta y_pred] = sigmoid_fit(x,y);
% 
% This function fits a sigmoid curve to psychometric function data and
% outputs parameter estimates and predicted y values. 
%
% x should be a vector of levels of IV, and y should be DV mean measured at
% each level. x and y must have equal length. 
%
% output are parameter values gamma and theta and a vector of predicted y
% values given the input x vector and model fit. 
%
% ----------------------------------------------------------------------- %

% Later I will add some checks, but for now it just will error if the
% inputs are wrong - I am in a hurry. 

function [gamma theta y_pred,residual] = sigmoid_fit(x,y)

    gamma_start = .5;
    theta_start = .1;

    params = [gamma_start,theta_start];
    
    [paramvals,resnorm,residual] = lsqcurvefit(@sigmoid,params,x,y);
    gamma = paramvals(1);
    theta = paramvals(2);
    
    y_pred = 1 ./ (1 + exp((-1*gamma).*(x + theta)));
    
end

% ----------------------------------------------------------------------- %

function y = sigmoid(params,x)
gamma = params(1,1);
theta = params(1,2);

y = 1 ./ (1 + exp((-1*gamma).*(x + theta)));

end