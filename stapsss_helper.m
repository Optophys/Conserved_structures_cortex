function [std_ratios, stabs_all_norm] = stapsss_helper(binnedSpikes, behaviour, bin_size)
    window = 2000/bin_size; %consider 1000ms windows around spikes
    stabs_all = nan(size(binnedSpikes,1),window*2+1);
    stabs_all_norm = nan(size(binnedSpikes,1),window*2+1);
    %compute STAPSSS
    for neuron=1:size(binnedSpikes,1)
        sp_times = find(binnedSpikes(neuron,:)>0);
        if length(sp_times)>round(length(behaviour)/(1000/bin_size)*.1) %include neurons > .1Hz
            stabs = zeros(length(sp_times),window*2+1); 
            for tt=1:length(sp_times)
                if sp_times(tt) < size(binnedSpikes,2)-(window+1) & sp_times(tt)>window+1 & ~isnan(behaviour(sp_times(tt)-window:sp_times(tt)+window))
                     stabs(tt,:) = behaviour(sp_times(tt)-window:sp_times(tt)+window);
                end
            end
           
            stabs_all(neuron,:) = nanmean(stabs(sum(stabs,2)~=0,:),1);         
        end
    end
    %normalize
    for neuron=1:size(binnedSpikes,1)
        if ~isnan(stabs_all(neuron,1))            
              stabs_all_norm(neuron,:) = stabs_all(neuron,:)/nanmean(stabs_all(neuron,:));       
        end
    end

    stabs_std = nanstd(stabs_all_norm,0,2); %compute std of spike-triggered-average  
 
    %assess statistical significance
    %compute control distribution
    
    control_size = 10; 
    stabs_control = zeros(size(binnedSpikes,1),control_size,2*window+1);
    stabs_control_norm = zeros(size(binnedSpikes,1),control_size,2*window+1);
    p_level = .99;
    for neuron=1:size(binnedSpikes,1)
        if ~isnan(stabs_all(neuron,1))
            for i=1:control_size
                sp_times = find(circshift(binnedSpikes(neuron,:),randi(100000+window)+2*window)>0);
                stabs = zeros(length(sp_times),window*2+1);
                counter = 0;
                for tt=1:length(sp_times)
                    if sp_times(tt) < size(binnedSpikes,2)-(window+1) & sp_times(tt)>window+1 & ~isnan(behaviour(sp_times(tt)-window:sp_times(tt)+window))
                         stabs(tt,:)= behaviour(sp_times(tt)-window:sp_times(tt)+window);
                         counter = counter + 1;
                    end
                end                  
                stabs_control(neuron,i,:) = nanmean(stabs(sum(stabs,2)~=0,:),1);       

                stabs_control_norm(neuron,i,:) = stabs_control(neuron,i,:)/nanmean(stabs_control(neuron,i,:));
              
            end
        end
    end
%     

    std_ratios = nan(1, size(binnedSpikes,1));
    for neuron=1:size(binnedSpikes,1)
        if ~isnan(stabs_all(neuron,1))
            control_stds = nanstd(stabs_control_norm(neuron,:,:),0,3);
            std_ratios(neuron) = stabs_std(neuron) / quantile(control_stds,p_level);
      
        end
       
    end
    std_ratios(sum(binnedSpikes,2) == 0) = -1; %MU (SU with low firing rate: nan)
    stabs_all_norm(sum(binnedSpikes,2) == 0,:) = -1;


end