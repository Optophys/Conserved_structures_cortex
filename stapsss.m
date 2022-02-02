% script for STAPSSS

bin_size = 10;
smooth_spikes=false;
locobot_mode=true;


id_list = {'RatA_03082017_1333'};

 for j=1:numel(id_list)
    data = load(strcat(id_list{j}, '_spikes'));
    binnedSpikes = data.binnedSpikes;
    stance_fr = data.stance_front_right;
    stance_fl = data.stance_front_left;
    stance_hr = data.stance_hind_right;
    stance_hl = data.stance_hind_left;
   
   
    [std_ratios1, sta1] = stapsss_helper(binnedSpikes, stance_fr, bin_size);

    [std_ratios2, sta2] = stapsss_helper(binnedSpikes, stance_fl,  bin_size);

    [std_ratios3, sta3] = stapsss_helper(binnedSpikes, stance_hr,  bin_size);

    [std_ratios4, sta4] = stapsss_helper(binnedSpikes, stance_hl,  bin_size);
         
    stas =  {sta1,sta2,sta3,sta4};
    std_ratio = {std_ratios1, std_ratios2, std_ratios3, std_ratios4};



 end


