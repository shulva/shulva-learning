# Robot Learning intro

## intro

Agent会根据State和Goal做出Action。
Robot问题的独特之处在于Agent的行为Action是会影响现实世界的State，现实世界又会给予Agent反馈，直到Goal实现。
像[围棋](files/slides/CS231n/lecture_17.pdf#page=14)就是一个例子。Slides中有很多例子。
![lecture_17, 页面 9](files/slides/CS231n/lecture_17.pdf#page=9)

但是机器人如何接受现实世界的State呢？换句话说，Agent怎么**感知**这个世界呢？

> Robot Vision 

1.  **具身性 (Embodied)**：视觉不是被动的看，而是与身体动作紧密耦合的。机器人的每一个动作（如移动、转头）都会直接改变它看到的画面，视觉是动作反馈的一部分。
2.  **主动性 (Active)**：机器人不是被动接收数据，而是有目的的观察者。为了完成任务（如看清遮挡物），它可以主动选择视角、移动位置，去获取最有价值的视觉信息。
3.  **环境依赖性 (Situated)**：Robots are situated in the world.它处理的不是抽象的图片，而是必须实时应对当前物理环境的复杂变化（如光照、障碍物），视觉直接决定了它当下的生存和行为。

A key challenge in Robot Learning is to close the perception-action loop.
![lecture_17, 页面 27](files/slides/CS231n/lecture_17.pdf#page=27)

Evaluation:评估机器人的好坏也是一个难点。

1.  **实地评估为主 (Real-world Evaluation)**:机器人模型的好坏，主要还得拉到**真实世界**里去溜溜。

2.  但是:**昂贵 (Costly and Noisy)**:在现实中搭场景、跑机器人非常烧钱且耗时。虽然像大厂有钱可以硬抗。
**相关性弱 (Weak Correlation)**: 你在电脑上训练时 Loss 降得很低（模型觉得自己学得很好），但这**并不代表**它在现实中抓取成功率就高。原因在于训练目标（Loss）和实际任务指标（Success Rate）不一致，以及训练和测试的环境差异。

![lecture_17, 页面 94](files/slides/CS231n/lecture_17.pdf#page=94)

## Reinforcement Learning

> Decision-Making problem

RL trains agents that interact with an environment and learn to maximize reward (trial and error)

> The difference between RL and Supervised Learning

这里是Supervised Learning的流程，和RL也很相像啊？到底有什么区别？不都是input output以及反馈的sequence吗？
![lecture_17, 页面 34](files/slides/CS231n/lecture_17.pdf#page=34)

此两者虽然流程上长得像，但是确实有很多区别。
第一点就是Environment的混沌性，同样的action不一定有同样的reward，robot影响的环境是一个混沌的动态系统。
第二点就是reward $r_t$ 并不是直接依赖于$a_t$，reward事实上可能是被以前的，累积的reward共同影响。就像下围棋，下错一步的影响可能不会立即显现，而是要过很久才会显现。
第三点，做不了反向传播，Loss是可微的，但是reward是环境给的，我们没法对现实世界求导。
第四点就是这里的Agent的Action $a_t$是会影响Environment以及下一步的State $S_{t+1}$的。Supervised Learning的上一步output输出可不会影响其他的input数据点。
![lecture_17, 页面 37](files/slides/CS231n/lecture_17.pdf#page=37)

> Deep Q-Learning

Q function takes  state and action as inputs, and $\theta$ is the parameter of this Q function. Q is a neural network.

> **Network input: state $s_t$: 4x84x84 stack of last 4 frames**

*   原始数据: 游戏屏幕的像素。预处理把彩图变成灰度图，缩小尺寸到 84x84。把**最近的 4 帧**叠在一起作为输入，这就给了神经网络**时间/动态**的信息，让它能感知速度和方向。

中间的，处理的数据的过程是一个经典的 CNN 结构，也就是Q网络：
*   `Conv(4->16...)`: 第一层卷积，提取基础视觉特征。`Conv(16->32...)`: 第二层卷积，提取更高级的特征。
*   **`FC-256`**: 全连接层，整合所有视觉信息。

> **"Network output: Q-values for all actions"**

*   DQN 输出的是4个 **Q值 (Q-values)**：**$Q(s_t, a_i)$**。这里对应上下左右四个动作

Conv 层的权重和偏置,FC 层的全连接层的权重矩阵和偏置就是参数$\theta$。

我们不能直接求导，因为没有“正确答案”告诉我们这个动作到底值多少分。DQN 用了一个“自举 (Bootstrapping)”方法，也就是“用未来的估计来更新现在的估计”**。

**更新公式 (Loss Function):**
$$ L = ( \underbrace{r + \gamma \max_{a'} Q(s', a'; \theta_{old})}_{\text{目标值 (Target)}} - \underbrace{Q(s, a; \theta)}_{\text{预测值 (Prediction)}} )^2 $$

*   **预测值**: 现在的网络算出来的 $Q(s, a)$。
*   **目标值**:
    1.  你执行了动作 $a$，环境立刻给了你一个reward $r$。
    2.  你到了新状态 $s'$，你再问一遍网络（用老参数 $\theta_{old}$）：在 $s'$ 那个状态下，最好的动作能拿多少分？($\max Q(s', a')$)
    3.  **目标 = 眼前奖励 + 未来最好的预期**。

之后算出 Loss。反向传播，梯度下降就好。

> [!example] 有点难以理解？
> 如果它预测某步棋值 80 分，但你照做后发现实际只得到了 0 分奖励，不过这步棋让你到了一个能在未来拿 90 分的好位置，那么它就会意识到这步棋的真实价值其实是 81 分（0 + 0.9×90），比预测值要高。于是它会通过Loss+反向传播修正参数，下次再遇到类似情况就会预测得更准。

![lecture_17, 页面 40](files/slides/CS231n/lecture_17.pdf#page=40)

Alpha Go的成功说明了一件事：

	 Sometimes , making this method simpler will actually give you better performance by making it morecompatible by whatever infrastructure you can use for scale things up

还有其他[Games](files/slides/CS231n/lecture_17.pdf#page=47)上的成功。
![lecture_17, 页面 46](files/slides/CS231n/lecture_17.pdf#page=46)


> Problem of Model-Free Reinforcement Learning -> Model-Based RL

这一类直接从经验中学习策略的方法是有问题的。
它是靠试错。它没有推理能力，只能一次次地去犯错，并从错误中吸取教训。
需要成千上万次，甚至上亿次的尝试才能学会一个简单的动作。这在现实世界（比如机器人控制）中是不可接受的，太慢了。

> Safety concerns

因为它是试错学习，这就意味着在它学会正确操作之前，它一定会尝试很多**错误**的操作。在游戏里死一万次没关系，但在现实世界里，如果你让一个自动驾驶汽车或手术机器人通过“试错”来学习，那代价不可承受。

> What if things go wrong?

 这是一个黑盒子。它只是记住了行为，但它**不知道为什么**。如果出了事故，我们也搞不清楚它怎么想的，很难调试和信任。

> Humans maintain an intuitive model of the world

*   人类不是靠盲目试错学习的。我们脑子里有一个**世界模型 (World Model)**。我们不用真的切到手，就知道“刀很锋利，切到手会流血”。这就是在脑子里模拟了结果。世界模型的知识可以**Widely applicable**，这个物理常识推广在其他任何地方。而且很高兴，很**Sample efficient**，我们只需要看一次或者想一下就能学会，不需要犯错误才学会。

**我们需要 Model-Based RL**，也就是让 AI 先学会一个**世界模型**（比如知道物理规律），然后在脑子里模拟和规划，而不是在现实中拿错误去试。

![lecture_17, 页面 52](files/slides/CS231n/lecture_17.pdf#page=52)


---

## Model Learning & Model-Based Planning

	 The key idea is you want to learn the model from robot's physical interactions with the real physical world and using that learned model is very effective in helping the robot to decide the behaviors to progress with the task objective.

> Use planning through the model to make decisions

*   **任务**: 学习一个有个世界状态转移函数 $P(s_{t+1} | s_t, a_t)$的模型。输入$s_t$，$a_t$，它就能预测出你下一步会变成什么样 $s_{t+1}$。
Green是预测点 Red是目标点 这两者之间的差异相当于Loss，需要minimize.

> Model might not be accurate enough

*   因为我们的模型可能不准（模拟和现实有差距），所以先**Execute the first action**，只执行计划好的第一步。再**Obtain new state**，看看实际上发生了什么，到了哪里。之后再通过梯度下降来优化action sequence。

但是，我们应该用什么来代表State？
![lecture_17, 页面 55](files/slides/CS231n/lecture_17.pdf#page=55)


> What should be the form of $s_t$?

**1. Pixel Dynamics (像素动力学)**
*   **状态形式**: **整张图片（原始像素）**。训练一个视频预测模型。输入当前的一帧画面，预测下一帧画面是什么样子的。
信息最全，什么都在里面。通用性强，不需要预处理。但是太难了！预测几百万个像素的变化非常困难且计算量巨大。

![lecture_17, 页面 56](files/slides/CS231n/lecture_17.pdf#page=56)

 **2. Keypoint Dynamics (关键点动力学)**
*   **状态形式**: **物体上的几个关键点坐标**（比如关节位置、物体中心点）。先用一个检测器找出图中的几个红点、绿点，然后只预测这几个点在下一刻会移动到哪里。优点是极其高效，从几百万个像素简化成了几十个坐标数字，计算快得多。缺点是只能描述刚体或者简单结构。如果是一块布、一堆沙子，几个点根本描述不清楚。

 **3. Particle Dynamics (粒子动力学)**
*   **状态形式**是一大堆粒子（点云）。其把物体看作是由成百上千个小粒子组成的。预测每一个粒子的运动。特别适合描述**流体**或者柔性物体的过程。比关键点更细致，比像素更结构化。
![lecture_17, 页面 60](files/slides/CS231n/lecture_17.pdf#page=60)

---
## Imitation Learning

> 学习人类的演示

	We have the demonstration collected by the experts. Then we will use that as a training data to do supervised learning to trying this policy. And we will roll out the policy in the real environment and observe those failure cases.And we either collect additional data or provide corrective behaviors that allow those datasets to not only contain the initial demonstrations but also those corrective behaviors that gets the errors from the policy back to the canonical trajectory.

![lecture_17, 页面 72](files/slides/CS231n/lecture_17.pdf#page=72)

> 那么该如何选择这里的policy呢？

1.  **IRL (Inverse Reinforcement Learning)**
    *   **核心机制**：通过观察专家演示，逆向推导其背后的**奖励函数 (Reward Function)**，即理解任务的目标和约束。
    *   **应用方式**：获得奖励函数后，再利用强化学习 (RL) 训练策略以最大化该奖励，从而复现专家行为。

2.  **IBC (Implicit Behavior Cloning)**
    *   **核心机制**：采用**基于能量的模型**来表示策略，学习一个能量函数，使得专家动作对应低能量值。
    *   **应用方式**：推理时，通过优化算法在动作空间中搜索能量最低的动作作为输出。

3.  **Diffusion Policies**
    *   **核心机制**：将策略建模为一个**条件扩散模型**，学习从高斯噪声中逐步去噪以恢复专家动作分布的过程。
    *   **应用方式**：推理时，从随机噪声开始，通过迭代去噪生成连续、平滑且多模态的动作序列，是目前模仿学习中的 SOTA 

---
## VLA

VLA不像传统方法那样去显式地建模状态或转移函数。本质上是一个**端到端的大型策略 (Policy)**：直接将观测/状态和目标映射到动作 ($Observation/State, Goal \rightarrow Action$)。

现有的 VLM（如 GPT-4V）输出可能不总是完美 (Perfect) 的，但总是合理 (Reasonable) 的。
同理，机器人基础模型生成的动作可能不是最优 (Optimal) 的，但生成的轨迹总是优美且合理的。
![lecture_17, 页面 82](files/slides/CS231n/lecture_17.pdf#page=82)

---
### Case Study:Pi-Zero

最左边是dataset。

中间上面是Pre-Training以及Post-Training部分。
- Pre-Training部分互联网上海量的图文数据进行预训练。也 使用包含多种不同机器人的大规模开源数据集。
它是一个 **Vision-Language-Action (VLA)** 模型。内部包含一个已经预训练好的VLM（负责理解图像和文本指令，如 fold shirt）。同时也结合了一个专门的动作专家模块（负责输出具体的机器人控制指令）。这是为了让模型学会理解任务，并具备跨机器人的基础操作能力。
- Post-Training部分则是为了那些比较困难且specific的任务再专门训练。

最右边则是效果：
*   **Zero-shot**: 对于训练数据中常见的任务（in-distribution），比如收拾桌子，它不需要额外训练就能直接干。
*   **Specialized**: 对于高难度的任务（如叠衣服），经过Post-Training，它能做得非常好。
*   **Efficient**: 对于从未见过的任务（unseen tasks），它只需要很少的数据进行Post-Training就能快速学会。

![lecture_17, 页面 86](files/slides/CS231n/lecture_17.pdf#page=86)


