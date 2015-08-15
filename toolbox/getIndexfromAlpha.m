%get the max and min index from alpha_max and alpha_min
function [index_min, index_max] = getIndexfromAlpha(numofplane, alpha_min, alpha_max, cor_source, cor_det, cor_plane1, cor_plane2, delta_cor)

if(cor_det-cor_source>=0)
    index_min = ceil(numofplane-(cor_plane2-alpha_min*(cor_det-cor_source)-cor_source)/delta_cor);
    index_max = floor(1+(cor_source+alpha_max*(cor_det-cor_source)-cor_plane1)/delta_cor);
elseif(cor_det-cor_source<0)
    index_min = ceil(numofplane-(cor_plane2-alpha_max*(cor_det-cor_source)-cor_source)/(delta_cor));
    index_max = floor(1+(cor_source+alpha_min*(cor_det-cor_source)-cor_plane1)/(delta_cor));
end;