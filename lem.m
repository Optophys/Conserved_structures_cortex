function ResultArray=LEM(spikes,p_neighbors_vec)
% adapted from Rubin et al. Code
%Inputs:

%spikes: N-by-T activity matrix, N is number of neurons
%and T is number of time frames 

%p_neighbors_vec: 1-by-2 vector of portion of neighbors that are considered close. First
% entries for first and second iteration

%Output:
%ResultArra:  First cell data LEM, second cell eigenvectors


p_neighbors1=p_neighbors_vec(1);
p_neighbors2=p_neighbors_vec(2);

data = spikes';
N = size(data,1);

knn    = ceil(p_neighbors1*N); 

m = size(data,1);
dt = squareform(pdist(data, 'hamming')); 

[srtdDt,srtdIdx] = sort(dt,'ascend');
dt = srtdDt(1:knn+1,:);
nidx = srtdIdx(1:knn+1,:);

tempW  = ones(size(dt)); %weights are always 1

% build weight matrix
i = repmat(1:m,knn+1,1);
W = sparse(i(:),double(nidx(:)),tempW(:),m,m); 
W = max(W,W'); 

num_dims = 20; 

% get eigenvectors
[v,d] = eigs(diag(sum(W,2))-W,diag(sum(W,2)),num_dims,'sa'); %la

data2 = [v(:,1:num_dims)];
N                = size(data2,1);
knn    = ceil(p_neighbors2*N); % each patch will only look at its knn nearest neighbors in R^d

m                = size(data2,1);
dt               = squareform(pdist(data2));
[srtdDt,srtdIdx] = sort(dt,'ascend');
dt               = srtdDt(1:knn+1,:);
nidx             = srtdIdx(1:knn+1,:);

tempW  = ones(size(dt));

i = repmat(1:m,knn+1,1);
W = sparse(i(:),double(nidx(:)),tempW(:),m,m); 
W = max(W,W');

[v2,d2] = eigs(diag(sum(W,2))-W,diag(sum(W,2)),num_dims,'sa'); 

ResultArray{1}= v2;
ResultArray{2} = d2;