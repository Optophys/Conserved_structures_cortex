
names = {'RatC_26062017_0906', 'RatB_21082017_0910','RatA_03082017_1333' }; 

for i=1:numel(names)    
    sessionName=names{i};
    data = load(strcat(sessionName, '_lem'));
    v2 = data.lem;
    v2_labels = data.behavior_labels;
    dists = pdist(v2);    
    radii = logspace(log10(.00005), log10(max(dists)*.9), 50); 
    mean_neighbors = zeros(numel(radii), 7);
    for j=1:numel(radii)
        idx = rangesearch(v2,v2, radii(j));
        cellsz = cellfun(@numel,idx,'uni',false);
        mean_neighbors(j, 1) = mean(cell2mat(cellsz));
        for a=1:6
            v2_a = v2(v2_labels==a,:);
            idx = rangesearch(v2_a,v2_a, radii(j));
            cellsz = cellfun(@numel,idx,'uni',false);
            mean_neighbors(j, a+1) = mean(cell2mat(cellsz));                       
        end        
    end
    slopes = zeros(7,1);
    nn=2;
    for a=1:7
        x=radii;
        y = mean_neighbors(:, a).';
        grad = gradient(log10(y), log10(x));
        [~, max_p]= max(grad);
        start = max(1, max_p-nn);
        end_ind = min(numel(x), max_p+nn);
        Bp = polyfit(log10(x(start:end_ind)), log10(y(start:end_ind)), 1);
        slopes(a) = Bp(1);     %slopes(1) gives whole dimensionality   
    end       
end
