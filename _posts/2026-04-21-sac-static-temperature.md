---
layout: post
title: SAC (Static temperature)
date: 2026-04-21
tags:
  - research
  - paper
---

# Summary
RL methods and the ability of neural networks to approximate function have the potential to automate a wide range of decision making and control processes. Unfortunately they have been hampered by two main problems. 1. Model-free deep RL methods have high sample complexity. This means that even simple tasks may need millions of steps of sample collection, and complex high dimensional tasks might need even more.They are also brittle with respect to their hyper parameters requiring extensive tuning of hyper parameters to achieve good performance. The soft actor critic algorithm aims to solve these problems. Which it does in some ways, but I think that these two problems are still the main ones being solved in this feild. For example the [TD-MPC]({% post_url 2026-04-10-summary %}) and TD-MPC2 algorithms both claim to solve problems that are very similar to the ones stated in this paper.

The paper claims that one of the reasons that there is such high sample complexity is because many previous algorithms used on-policy learning which is less sample efficient because it effectively throws away past data. This motivated their use of an off-policy learning algorithm.


## Novelty 
The authors of this paper aim to solve the two problems stated above by extending the maximum entropy framework to off-policy learning for continuous action control problems which had not been done previously. 
## Problem Setup

### General Robotic Control Problem Setup 
In this paper they consider the classic robotic control setup, which is as follows. Consider the infinite-horizon Markov Decision Process (MDP) characterized by the tuple <script type="math/tex">(\mathcal{S}, \mathcal{A}, \mathcal{T}, \mathcal{R},\gamma,p_{0})</script>, where <script type="math/tex">\mathcal{S}\in \mathbb{R}^n</script> and <script type="math/tex">\mathcal{A}\in\mathbb{R}^m</script> are continuous state and action spaces. <script type="math/tex">\mathcal{T}: \mathcal{S} \times \mathcal{A}\times\mathcal{S} \to \mathbb{R}_{+}</script> is the transition function between an observation and the next observation given some action. <script type="math/tex">\mathcal{R}: \mathcal{S}\times\mathcal{A} \to \mathbb{R}</script> is a reward function, <script type="math/tex">\gamma \in[0,1)</script> is a discount factor, and <script type="math/tex">p_{0}</script> is some initial state distribution. The model from the paper aims to learn a parameterized mapping <script type="math/tex">\Pi_{\theta}: \mathcal{S} \to \mathcal{A}</script> with parameters <script type="math/tex">\theta</script> such that the discounted return is maximized along a trajectory. 

## Method
The authors of this paper use function approximations (neural networks) for both the Q-function and the policy. Instead of running evaluation and improvement to convergence they alternate between optimizing both networks with stochastic gradient decent. 

### Policy
One of the main ideas of the maximum entropy definition as defined in the SAC paper is that the policy jointly optimizes both the cumulative reward over time and the randomness of each action. The objective of the policy is then mathematically defined as:

<script type="math/tex; mode=display">
J(\pi) = \sum_{t=0}^{T} \mathbb{E}_{(s_t, a_t) \sim \rho_\pi} \left[ r(s_t, a_t) + \alpha \mathcal{H} \big( \pi(\cdot \mid s_t) \big) \right].
</script>

where <script type="math/tex">r</script> is the critic or value network sometimes called Q and <script type="math/tex">\alpha</script> is the temperature, and <script type="math/tex">\mathcal{H}</script> is the entropy of the policy. 

### Q-network Value & Soft value 
They implement Q networks using an ensamble of two MLPs. They train each of these MLPs independently and use the minimum value of the two for policy updates which minimize the optimism that Q-networks sometimes display. The networks are trained to minimize the following function:
<script type="math/tex; mode=display">
J_Q(\theta) = \mathbb{E}_{(s_t, a_t) \sim \mathcal{D}} \left[ \frac{1}{2} \left( Q_\theta(s_t, a_t) - \hat{Q}(s_t, a_t) \right)^2 \right]
</script>
In the original paper it was noted that instead of computing the soft value of an action (The value of the action plus its randomness) from the value function itself it was stated that in practice it seemed more stable to instantiate another network to predict this value. This network is trained with the following objective function. 

<script type="math/tex; mode=display">
J_V(\psi) = \mathbb{E}_{s \sim \mathcal{D}} \left[ \frac{1}{2} \left( V_\psi(s) - \mathbb{E}_{a \sim \pi_\phi(\cdot \mid s)} \big[ Q_\theta(s,a) - \alpha \log \pi_\phi(a \mid s) \big] \right)^2 \right]
</script>
In more modern implementations this is just computed using the following equation:

<script type="math/tex; mode=display">
V(s') \approx Q(s', a') - \alpha \log \pi(a' \mid s'), \quad a' \sim \pi
</script>

## Results
The results show that SAC not only has higher sample efficiency, but it seems to also have better asymptotical performance than many on and off policy models. It also is more robust to hyperparameters, but does require extensive tuning of the models temperature. The figure below was adapted from the SAC paper.

![SAC performance comparison]({{ '/assets/images/sac-static-temperature-results.png' | relative_url }})

---

# Deep Understanding


## Why it works
- I think there are several reasons why this model seems to work well. One is that it takes advantage of entropy which effectively explores the action space while maximizing reward. To this end the maximum entropy seems to do well in situations where the optimal action distribution is multimodal, by effectively placing distribution mass in both effective action distributions which is better than many other model such as PPO. 
- It certainly seems more sample efficient, but that is to be expected due to its off-policy nature. Instead of throwing away past data it reuses it which makes a lot of sense. It still is not as sample efficient as model based algorithms, but it is much simpler

## Limitations
- One of the major limitations I think for this first version of SAC is the need to tune the temperature parameters. This problem was addressed in later papers, but having to tune this value negates any of the benefits that might come from being robust to hyperparameters. 

---

# Connections

## Related Work
- [TD-MPC]({% post_url 2026-04-10-summary %}) and TD-MPC2 both use the maximum entropy framework which is formulated in much the same way. 
- There have been newer editions to SAC that fix some of the problem including the temperature tuning problem. 

## My Thoughts
- I think that SAC seems like a reliable and good algorithm. If the application can support more stochastic policies I think this should be the go to one because it is sample efficient, relatively simple and used very often. 

---

# Research Ideas
One of the main ideas that I have to extend from SAC is to remake the function approximators using GNNs which will allow a single SAC model to extend to any topology. If this works in practice is debatable, but I think the tools are certainly there to do this. 

---

# Source
[1] Haarnoja, T., Zhou, A., Abbeel, P., and Levine, S., 2018, “Soft Actor-Critic: Off-Policy Maximum Entropy Deep Reinforcement Learning with a Stochastic Actor,” _Proceedings of the 35th International Conference on Machine Learning_, PMLR, pp. 1861–1870. [Online]. Available: [https://proceedings.mlr.press/v80/haarnoja18b.html](https://proceedings.mlr.press/v80/haarnoja18b.html). [Accessed: 11-Feb-2026].
