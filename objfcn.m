function f = objfcn(x)

x = x(:);

n = length(x);
xx = x(1:n/2);
yy = x(n/2+1:end);


f = sum(hypot(xx(2:end)-xx(1:end-1),yy(2:end)-yy(1:end-1)));