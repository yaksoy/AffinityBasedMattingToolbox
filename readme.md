Affinity-Based Matting Toolbox
=================================================================

About
------------

This toolbox includes a collection of common affinity-based image matting algorithms as well as matte refinement algorithms used by sampling-based image matting methods.
It features the only public (re-)implementation of information-flow matting [AAP17], a faster matting Laplacian [LLW08] computation and a faster trimap trimming [SRPC13].
The parameters for each algorithm are easily customizable.

The included matting algorithms are:

- Information-flow matting [AAP17]
- KNN matting [CLT13]
- Closed-form matting [LLW08]

The included matte refinement algorithms are:

- Information-flow matte refinement [AAP17]
- Shared matting matte refinement [GO10]

The included trimap trimming methods are:

- Patch-based trimming [AAP17]
- Trimming from known-unknown edges [SRPC13]

The toolbox is designed to be ease of use for an extended set of applications.
Sparse affinity matrices defined and used in [AAP17, CLT13, CZZT12, LLW08] can be obtained by calling the corresponding functions inside 'affinity' directory.
The functions in this directory allow defining regions for neighborhood search.

An example image-trimap pair from the alpha matting benchmark [RRW09] is provided.
Basic features are demonstrated in the demo file.
Each function features an explanation and definitions of related parameters.

The information-flow matting function in this toolbox is not the original implementation used in the paper.
These are reimplementations of the original methods and may not give the exact same results as reported in the corresponding papers.

Planned extensions
------------
I plan to add the layer color estimation methods, as well as LNSP matting and multiple-layer matte estimation methods in the near future.
I may tweak the information-flow matting implementation to achieve its original performance on the benchmark.
Feel free to contribute or propose a method to be added to the toolbox by [contacting me](http://people.inf.ethz.ch/aksoyy/contact/).

License and citing the toolbox
------------

This toolbox is provided for academic use only.
If you use this toolbox for an academic publication, please cite corresponding publications referenced in the description of each function, as well as this toolbox itself:

    @MISC{abmt,
    author={Ya\u{g}\{i}z Aksoy},
    title={Affinity-based matting toolbox},
    year={2017},
    howpublished = {\url{https://github.com/yaksoy/AffinityBasedMattingToolbox}},
    }

References
------------
[AAP17] Yagiz Aksoy, Tunc Ozan Aydin, Marc Pollefeys, "Designing Effective Inter-Pixel Information Flow for Natural Image Matting", CVPR, 2017. [[link](http://people.inf.ethz.ch/aksoyy/ifm/)]

[CLT13] Qifeng Chen, Dingzeyu Li, Chi-Keung Tang, "KNN Matting", IEEE TPAMI, 2013. [[link](http://dingzeyu.li/projects/knn/)]

[CZZT12] Xiaowu Chen, Dongqing Zou, Qinping Zhao, Ping Tan, "Manifold preserving edit propagation", ACM TOG, 2012 [[paper](http://www.cs.sfu.ca/~pingtan/Papers/sigasia12.pdf)]

[GO10] Eduardo S. L. Gastal, Manuel M. Oliveira, "Shared Sampling for Real-Time Alpha Matting", Computer Graphics Forum, 2010. [[link](http://www.inf.ufrgs.br/~eslgastal/SharedMatting/)]

[LLW08] Anat Levin, Dani Lischinski, Yair Weiss, "A Closed Form Solution to Natural Image Matting", IEEE TPAMI, 2008. [[paper](http://people.csail.mit.edu/alevin/papers/Matting-Levin-Lischinski-Weiss-PAMI.pdf)]

[RRW09] Christoph Rhemann, Carsten Rother, Jue Wang, Margrit Gelautz, Pushmeet Kohli, Pamela Rott, "A Perceptually Motivated Online Benchmark for Image Matting", CVPR 2009. [[link](http://alphamatting.com)]

[SRPC13] Ehsan Shahrian, Deepu Rajan, Brian Price, Scott Cohen, "Improving Image Matting using Comprehensive Sampling Sets", CVPR 2013 [[paper](http://www.cv-foundation.org/openaccess/content_cvpr_2013/papers/Shahrian_Improving_Image_Matting_2013_CVPR_paper.pdf)]