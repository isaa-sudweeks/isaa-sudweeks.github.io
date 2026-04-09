---
layout: post
title: Test-TDMPC2
date: 2026-04-08
tags:
  - research
  - paper
---
 # Key Findings and How I am going to implement this

It seems that using this algorithm could also help to enable the robot to do many different tasks other than simply move forward.

The main contribution of this work seems to be that a single model can be trained to do many different tasks, and even cooler the hyper parameters don’t seem to need to be optimized for the model to perform well on many different things.

The idea of **TD-MPC** is that a world model is learned with a latent space of lower dimensional and then MPC is then used to optimize trajectories in this latent space using the world model. The output of this MPC will invariable be a locally optimal policy and is not guaranteed nor likely to be a solution to the general RL problem, to overcome this TD-MPC2 bootstraps the return estimates beyond the horizon with a learned terminal value function.

## Learning an Implicit World Model

The idea is that instead of decoding future predicted observations the network just passes the latent representation. So it basically just has an encoder.

The **Model Objective** is to joinly optimize h, d, R, Q which is to minimize the objective function. The objective function is sort of the combined loss of a few things:

1. The L2Norm or MSE of the joint embedding prediction. Otherwise know as the difference between the predicted next state and the actual next state in latent space. The only weird thing here is that there is an SG operator which is the stop gradient operator. It is there to prevent the network from effectivly cheating because if it wasn’t there it could optimize both sides of the equation at the same time.
2. Cross Entropy of the predicted reward verses the actual reward.
3. Cross Entropy of the actual value prediction verses the predicted value prediction.

The reason that these regression tasks are using cross entropy is because the magnitude of rewards may differ a lot between different tasks, this reformulation allows the optimizer to perform discrete regression in a log transformed space which works better.

I do not understand the policy objective.

# Architecture

All components of TD-MPC2 are implemented as MLPs with intermediate linear layers followed by LayerNorm, and Mish motivations.

Exploding gradients are mitigated by normalizing the latent representation by projecting Z into L fixed-dimensional simplistic using softmax operations **I don’t know how this works at all.**

They are talking about something called SimNorm **I do not understand this either.**

They use 5-Q-function ensemble to estimate Q and the TD targets are computed as the minimum of two randomly sub-sampled Q functions.

Put images of equations 1 and 2 here

# Questions

- How does this model work with many different action spaces?
- How does it learn?
    
    - During training a replay buffer is maintained the world model is updated using sampled data from the replay buffer and new data is collected using the MPC planning
- Why does the model only use an encoder and not a deconder?
# Source
[1] Hansen, N., Su, H., and Wang, X., 2024, “TD-MPC2: Scalable, Robust World Models for Continuous Control.” [https://doi.org/10.48550/arXiv.2310.16828](https://doi.org/10.48550/arXiv.2310.16828). 