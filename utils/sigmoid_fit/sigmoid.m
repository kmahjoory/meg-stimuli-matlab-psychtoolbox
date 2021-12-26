function y = sigmoid(gamma, theta,x)

y = 1 ./ (1 + exp(-1*gamma*(x + theta)));

end