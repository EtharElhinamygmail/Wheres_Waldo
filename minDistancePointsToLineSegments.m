function dist = minDistancePointsToLineSegments(pts,lineSegs) %#codegen
% Given a set of points p, with coordinates [px,py], and line segments 
% lineSegs - find the distance between each point and the nearest line
% segment.

dist = zeros(size(pts,1),size(lineSegs,1)-1);

for i = 1:size(pts,1)
    for j = 1:size(lineSegs,1)-1
        if dot(pts(i,:)-lineSegs(j,:),lineSegs(j+1,:)-lineSegs(j,:)) < 0
            dist(i,j) = norm(pts(i,:)-lineSegs(j,:));
        elseif dot(pts(i,:)-lineSegs(j+1,:),lineSegs(j,:)-lineSegs(j+1,:)) < 0
            dist(i,j) = norm(pts(i,:)-lineSegs(j+1,:));
        else
            dist(i,j) = abs(det([lineSegs(j+1,:)-lineSegs(j,:);lineSegs(j,:)-pts(i,:)]))/...
                norm(lineSegs(j+1,:)-lineSegs(j,:));
        end
    end
end

dist = min(dist,[],2);