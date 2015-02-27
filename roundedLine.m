function roundedLine(x,y,radius)

t = linspace(0,2*pi);
lineColor = [1.0 0.91 0.91];

for i = 1:length(x)-1
    [rx,ry] = rectangleAroundLine([x(i) y(i)],[x(i+1) y(i+1)],radius);
    patch(rx,ry,lineColor,'LineStyle','none');
    cx = x(i)+radius*cos(t);
    cy = y(i)+radius*sin(t);
    patch(cx,cy,lineColor,'LineStyle','none');
end

cx = x(end)+radius*cos(t);
cy = y(end)+radius*sin(t);
patch(cx,cy,lineColor,'LineStyle','none');