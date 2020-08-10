function [vv,rep_sz] = dimfit(v,u,varargin)
% Replicate array to fit wanted size.
%
% INPUT:
%   dimfit(v,u) - v will be replicated to fit the dimensions of u
%   dimfit(v,m,n,k,..) - v will be replicated to match size [m,n,k,..]
%   i.e:
%   dimfit(v,u), is the same as: dimfit(v,size(u,1),size(u,2),..size(u,N))
%
%
% OUTPUT:
%   vv - [v] after it was replicated along the "missing" dimensions
%   rep_sz - the size used in repmat(). i.e. vv = repmat( v , rep_sz );
%
% EXAMPLE:
%   v = [ 1 2 ];
%   u = [ 11 12 ; 13 14 ];
%
%   vv = dimfit(v,u)
%      returns: vv = [ 1 2 ; 1 2 ]
%
%   Same as giving the size of u:
%   vv = dimfit(v,size(u,1),size(u,2))

if ~isempty(varargin)
    u_sz = [u;varargin{:}]';
else
    u_sz = size(u);
end

v_sz = ones(size(u_sz));
v_sz(1:length(size(v))) = size(v) ;

rep_sz = ones(size(v_sz));
if any(v_sz ~= u_sz & v_sz ~= 1)
    error([ 'Cannot fit dimensions.' ...
        ' Dimension of arrays must either match, or be equal to 1 ']);
end
rep_sz(v_sz ~= u_sz) = u_sz(v_sz ~= u_sz) ;

vv = repmat( v , rep_sz );