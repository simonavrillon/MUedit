# MUedit

MUedit is a Matlab app that decomposes electromyographic (EMG) signals recorded from multiple electrodes into individual motor unit pulse trains using fast independent component analysis (fastICA). You can easily adjust the parameters of the algorithm to the specificity of your experimental settings. After the decomposition, you can display and edit the output of the fastICA, i.e., the motor unit pulse trains.

## Getting started

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=simonavrillon/MUedit&project=https://github.com/simonavrillon/MUedit/blob/main/MUedit.prj)

We provide a step-by-step protocol (User_manual.pdf) to facilitate the implementation of MUedit in any experimental settings. You can also read our paper that describes the method, the main steps of the experiments, and the capabilities of the app (https://pubmed.ncbi.nlm.nih.gov/38761514/).

You can download the data presented in the paper at https://figshare.com/projects/Data_for_MUedit/172314

## Status

A new version of MUedit is available at https://github.com/simonavrillon/MUedit2. While the Matlab version will still be maintained, future features will be prioritarily implemented in this new Python/JavaScript version. We welcome any contributions to make the Matlab version of MUedit useful for the wider community.

## Related versions

A version of the decomposition algorithm coded with Python (Python 3.9.15) by Ciara Gibbs (ciara.gibbs18@imperial.ac.uk) is available at https://github.com/ciaragibbs/MUEdit_Python

## Citation

If you use MUedit in your experimental setting, please cite the following paper:

> Avrillon, S., Hug, F., Baker, S.N., Gibbs, C., and Farina, D. (2024). Tutorial on MUedit: An open-source software for identifying and analysing the discharge timing of motor units from electromyographic signals. J Electromyogr Kinesiol 77, 102886. 10.1016/j.jelekin.2024.102886.

## Support

The Matlab version of MUedit is mainly maintained by Paul Kaufmann ([@pauk98](https://github.com/pauk98)), Giovanni Traetta ([@innavoig23](https://github.com/innavoig23)), and Simon Avrillon.

For technical assistance and support, please contact:

Paul Kaufmann
PhD student, University Côte d'Azur
E-mail: paul.kaufmann@etu.univ-cotedazur.fr

Giovanni Traetta
PhD student, Nantes University
E-mail: giovanni.traetta@etu.univ-nantes.fr

Simon Avrillon
Research fellow, Nantes University
E-mail: simon.avrillon@univ-nantes.fr