function img = genphantom(Para)
	if (nargin == 0)
		toft = [  1   .69   .92    0     0     0   
        -.8  .6624 .8740   0  -.0184   0
        -.2  .1100 .3100  .22    0    -18
        -.2  .1600 .4100 -.22    0     18
         .1  .2100 .2500   0    .35    0
         .1  .0460 .0460   0    .1     0
         .1  .0460 .0460   0   -.1     0
         .1  .0460 .0230 -.08  -.605   0 
         .1  .0230 .0230   0   -.606   0
         .1  .0230 .0460  .06  -.605   0   
         ];
         size = 512;
         verBose = 1; figureBose = 1;
    else
	    if (isempty(Para.toft))
	    	toft = [  1   .69   .92    0     0     0   
	        -.8  .6624 .8740   0  -.0184   0
	        -.2  .1100 .3100  .22    0    -18
	        -.2  .1600 .4100 -.22    0     18
	         .1  .2100 .2500   0    .35    0
	         .1  .0460 .0460   0    .1     0
	         .1  .0460 .0460   0   -.1     0
	         .1  .0460 .0230 -.08  -.605   0 
	         .1  .0230 .0230   0   -.606   0
	         .1  .0230 .0460  .06  -.605   0   
	         ];
	    else
	    	toft = Para.toft;
	    end
	    size = Para.size;
	end

    % img = phantom(toft, size);

	img = (phantom(toft, size)/10)';

	if(Para.verBose); disp('Phantom has been generated'); end

	img = (img-0.02)/2+0.02;
	img(img<0.011) = 0;

	if(Para.figureBose); mysubplot([], img); end;

	