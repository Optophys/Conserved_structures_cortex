% cross-rat generalization after supervised alignment

label2str = ["step", "turn", "drink", "groom", "rear", "rest"];

names = {'RatC_26062017_0906', 'RatB_21082017_0910','RatA_03082017_1333' }; 

offset = 1; % 1 for lem, 0 for pca/isomap
num_dims = 20; 

mean_vectors_all = zeros(numel(names), 6, num_dims);

for n=1:numel(names)
    sn = names{n};
    try
         data = load(strcat(sn, '_lem'));
         v2 = data.lem;
         v2_labels = data.behavior_labels;
    catch ME
        continue
    end
    v2n = normalize(v2,1,'range');
    mean_vectors = zeros(6,size(v2,2));
    std_vectors = zeros(6,size(v2,2));
    for i=1:6
        mean_vectors(i,:) = mean(v2n(v2_labels==i,:),1);
    end
    mean_vectors_all(n,:,:) = mean_vectors;
    
end


train_labels_ = [1 2 3 4 5 6];
align_labels = combnk(train_labels_,4); % three or four
dec_dims = 4;
reps = 20; %number of repetitions
all_accs = zeros(reps,size(align_labels,1),numel(names),numel(names));
for rr=1:reps
    for com = 1:size(align_labels,1) 
        train_labels = setdiff(train_labels_, align_labels(com,:)); 
        for i= 1:numel(names)
            sn = names{i};           
            data = load(strcat(sn, '_lem'));
            v2 = data.lem;
            v2_labels = data.behavior_labels;
            v2n = normalize(v2,1,'range');
            trainidx = [];
            [a,~] = hist(v2_labels, setdiff(unique(v2_labels),0));
            a = a(ismember(setdiff(unique(v2_labels),0),train_labels_));
            for k=1:size(train_labels,2)
                ttidx =  datasample(find(ismember(v2_labels,[train_labels(k)])), round(.75*min(a)), 'Replace', false);
                trainidx = [trainidx ttidx];
            end
            testidx = setdiff(find( ismember(v2_labels, train_labels)), trainidx);
            mdl = fitcecoc(v2n(trainidx,1+offset:dec_dims+offset),v2_labels(trainidx), 'Learners', 'kernel');
            for j= 1:numel(names) 
                if i == j
                    testpred = predict(mdl, v2n(testidx,1+offset:dec_dims+offset));
                    acc = plot_confusion(v2_labels(testidx).',testpred, label2str(train_labels)); 
                    all_accs(rr, com, i, i) = acc;
                else 
                    sn2 = names{j};
                    data = load(strcat(sn2, '_lem'));
                    v2_2 = data.lem;
                    v2_2_labels = data.behavior_labels;
                    v2_2n = normalize(v2_2,1,'range');
                    mv1 = squeeze(mean_vectors_all(i,:,:));
                    mv2 = squeeze(mean_vectors_all(j,:,:));
                    p1 = mv1(align_labels(com,:),1+ offset:dec_dims+offset);
                    p2 = mv2(align_labels(com,:),1+offset:dec_dims+offset);
                    [d,Z,transform] =procrustes(p1,p2);
                    c = transform.c;
                    v2t=v2_2n(:,1+offset:dec_dims+offset)*transform.T*transform.b + c(1,:);
                    testpred = predict(mdl, v2t(ismember(v2_2_labels,train_labels),:));
                    acc = plot_confusion(v2_2_labels(ismember(v2_2_labels, train_labels)).',testpred, label2str(train_labels));
                    all_accs(rr, com, i, j) = acc;
                end
            end
        end
    end
end
