# Conserved_structures_cortex
Code for Paper "Conserved structures of neural activity in sensorimotor cortex of freely moving rats allow cross-subject decoding"
by Svenja Melbaum, Eleonora Russo, David Eriksson, Artur Schneider, Daniel Durstewitz, Thomas Brox, Ilka Diester.

This repository contains code with the most important methods used in the paper.
The following Matlab functions are contained:
- stapsss.mat: calculate spike-triggered average as in paper
- check_dim.mat: estimate intrinsic dimensionality of high-dimensional space
- lem.mat: dimensionality reduction using Laplacian Eigenmaps
- generalization.mat: train classifier on one animal, test on aligned neural manifold of another animal.
Small test datasets are provided.
