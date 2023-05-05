function    [rc]=rad_curv(vx,vy,deltaT)
%computes radius of curvature based on velocities
accx=zeros(length(vx),1);
accy=zeros(length(vy),1);
accx(2:end)=diff(vx)/deltaT;
accy(2:end)=diff(vy)/deltaT;
rc=zeros(length(vx),1);
for i=2:length(vx)
    %(vx(i)*accy(i)-vy(i)*accx(i))
    rc(i)=(vx(i)^2+vy(i)^2)^1.5/abs(vx(i)*accy(i)-vy(i)*accx(i));
end