function drawPath(xopt,pts,radius)
npts = length(pts.X);

roundedLine(xopt(1:npts),xopt(npts+1:end),radius);
hold on
axis equal
grid on
scatter(pts.X,pts.Y,'*');
plot(pts.X,pts.Y)
plot(xopt(1:npts),xopt(npts+1:end),'--k');
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])