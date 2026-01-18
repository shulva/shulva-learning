# Multi-Modal Foundation Models

## intro

> Now, we build Foundation Models

我们之前介绍的模型，基本上都是训练特定的模型去解决特定的任务。
**Pre-train** one model that acts as the **foundation** for many different tasks

![lecture_16, 页面 4](files/slides/CS231n/lecture_16.pdf#page=4)


> There are many classes of Foundation Models

How do identify a model as a Foundation?
- Always see with foundation models : general /robust to many different tasks
- Often see with foundation models : Large parameters, Large amount of data, Self-supervised pre-training objective

![lecture_16, 页面 9](files/slides/CS231n/lecture_16.pdf#page=9)

---
## Classification Foundation models

The main idea was to learning concepts without **labels** -> a self-supervised pretraining objective
做自监督学习的目的，是希望模型通过做这个任务，学到通用的、本质的特征，从而当它遇到全新的数据时能表现得很聪明。
我们能否将这些特征及其学习方法推广到图像以外的领域？比如推广到语言领域？
如果这个（原本用来放图像特征的）特征空间，也能用来嵌入（存放）句子或短语，那会怎么样？

---
### CLIP

> **CLIP (Contrastive Language-Image Pre-training)**

CLIP的[性能](files/slides/CS231n/lecture_16.pdf#page=22)表现的很好。
CLIP的形式类似SimCLR。网络上是有很多的图文相关的资料可供CLIP训练的。
注意，下面两个公式的分母是不同的！这里显然是配对的样本值越大越好，不配对的越小越好。
第一个公式相当于图片选文字,对于第i张图片$u_i$，它在所有n个文本中，可否识别出原配$v_i$?
第二个公式相当于文字选图片,对于第i个文本$v_i$，它在所有n个图片中，可否识别出原配$u_i$?
![lecture_16, 页面 16](files/slides/CS231n/lecture_16.pdf#page=18)

> At the end of training, you have a model that will give you a similarity score between an image and a text

![lecture_16, 页面 21](files/slides/CS231n/lecture_16.pdf#page=21)

> But how do we use pre-trained vision-language models in a zero-shot manner?

LLM的所有任务几乎都可以变换成**预测下一个词**的任务。如图，上面是预测任务，下面却是判断情感的任务。
那么 CLIP 这种看图的模型，是怎么完成**没见过这个分类任务，却能直接分类的**任务呢？
![lecture_16, 页面 23](files/slides/CS231n/lecture_16.pdf#page=23)


CLIP的方法是这样的：
假设你想使用CLIP模型作为基模去做以前没做过的分类任务，但又不想retrain模型，可以用如下措施：

- 把**图片**扔进 Image Encoder，得到图片向量 I

- 我们将多个标签填入多个Prompt，变成一堆句子：a photo/drawing/sketch... of a {dog}{plane}{bird}.
* 把这些句子全部喂给 Text Encoder，得到一堆向量。计算这些向量的**平均值 (Mean Vector)**。这个平均向量被称为 **`Mean "Dog" vector`**，这个向量可以更好地代表dog这个概念。

- 计算图片向量I与`Mean  vector`之间的相似度，哪个分数最高就分成哪个类。

这个简单的技巧能让 CLIP 在 ImageNet 上的分类准确率直接提升 **5%**。巨大的提升！
![lecture_16, 页面 31](files/slides/CS231n/lecture_16.pdf#page=31)

整体流程如下，这个图的计算过程比较清晰：
![lecture_16, 页面 32](files/slides/CS231n/lecture_16.pdf#page=32)

> Matches the accuracy of of ResNet 101 that has been trained on ImageNet, except CLIP was trained with no human labels at all! 

CLIP训练中没有人工标签，性能也一样可以匹敌在ImageNet上训练出的ResNet 101!
但是ImageNet在其他奇形怪状的dataset上表现不佳，但CLIP依然优秀！
虽然 CLIP 的 Zero-Shot 能力非常惊艳，但在面对一些**高度专业化**的任务时，传统的预训练+专门的线性分类器训练依然是更稳妥的[选择](files/slides/CS231n/lecture_16.pdf#page=38)。CLIP 并不是万能的，它强在**通用性**，而非特定领域的**专业性**。
![lecture_16, 页面 37](files/slides/CS231n/lecture_16.pdf#page=37)

> 为什么即使无标签，CLIP的性能还是这么出色？ Scale !

1.CLIP架构通过transformer架构扩大了参数量（Clip  (307 Million) vs ImageNet ResNet  (44.5 Million)）。
2.CLIP训练的数据量更多( Clip  (400 Million images) vs ImageNet ResNet (1.28 Million))。

---
### CoCa

 **CoCa (Contrastive Captioner)** 模型是对 CLIP 的一个重要升级。

CoCa 把两种强大的能力结合在了一个模型里：

*   Image Encoder 和 Unimodal Text Decoder 分别提取图像和文本的特征，然后进行对比学习（拉近正样本，推开负样本）。这保证了 CoCa 依然拥有像 CLIP 那样强大的**图文对齐**和**Zero-Shot 分类**能力。

*   CoCa 增加了一个 **Multimodal Text Decoder**。这个 Decoder 做的事情是：接收 Image Encoder 提取的图像特征（通过 `Cross-Attention`），然后生成描述这张图片的文字（Captioning）。

*   **CoCa**: 既能读也能写。它不仅能像 CLIP 一样做分类，还能生成描述这张图片的文字,是一个更全能的多模态基础模型。

![lecture_16, 页面 43](files/slides/CS231n/lecture_16.pdf#page=43)

### CLIP的优劣势

优势在于：
1.点积非常高效，无论是在训练还是在推理层面。
2.模型不再受限于训练时见过的固定类别，而是能够识别和理解任何用自然语言描述的新物体或新概念。
3.可以与其他模型组合。
![lecture_16, 页面 46](files/slides/CS231n/lecture_16.pdf#page=46)

劣势在于：
1.它太依赖 Batch Size，而且很难学到细粒度的概念。batchsize小，性能就很差。而且即使 Batch Size 很大，他也分辨不出"there is a mug in some grass" 与 "there is some grass in a mug" 之间的[差别](files/slides/CS231n/lecture_16.pdf#page=47&selection=12,0,12,5)。
其对复杂的语法关系和图片的空间逻辑的理解不够。用Hard Negative Fine-Tuning（对图片的错误描述施以严重惩罚）训练反而拖累性能。
2.对整个图片描述是ok的，但是对图片里面的物品的识别/描述确不行。
3.无法通过仅5B dataset处理世界上所有的图像问题，还需要做dataset的处理。

可见，CLIP还有很多工作要做。
![lecture_16, 页面 55](files/slides/CS231n/lecture_16.pdf#page=55)

---
## Vision-Language Model (VLM)

### LLaVA

> Can we build a model that can accept images and text as input, and then output text?

![lecture_16, 页面 57](files/slides/CS231n/lecture_16.pdf#page=57)


Vision-Language Models 并非LLaVA首创， ViLBERT就有了。但是，他们必须针对每一个任务分别进行微调，并且需要使用相当复杂的、特定于该任务的方法（在 RefCOCO 任务中，需要使用Mask-RCNN对边界框进行重排序）。==very task-specific== ,基模的处理逻辑可不是这样的。

LLaVA的想法就是将图片token化，之后加入到Transformer中。那么，我们该用什么方法呢？
![lecture_16, 页面 62](files/slides/CS231n/lecture_16.pdf#page=62)

用CLIP的Encoder是很好的选择！

在标准的 CLIP 训练中，我们使用的是**对比损失 (Contrastive Loss)**。把图片输入 ViT，ViT 输出一串特征向量（对应每个 image patch）。我们只取这一串向量中的**第一个**，也就是 **`[CLS]` token** 的输出向量。拿这个 `[CLS]` 向量去和文本向量计算相似度，算 Loss，更新参数。

其他token是没有supervised的，他们的输出可能没有任何意义。

虽然理论上存在这个问题，但实际上由于 ViT 内部深度的**自注意力机制**，Patch tokens 为了让 `[CLS]` token 能读懂，它们自己也会被迫学得很好（因为它们是 `[CLS]` 的信息来源）。

> 所以事实上一般不使用最后一层的输出，而是使用倒数第二层 (Penultimate Layer) 的输出

1.  **最后一层太专了 (Over-specialized)**:
    *   ViT 的**最后一层 (Final Layer)** 的主要任务是把图像特征压缩并对齐到文本特征空间，以便计算对比损失（Contrastive Loss）。这导致最后一层的特征往往变得非常抽象和全局化，甚至丢失了很多图像特有的空间细节（Spatial Information）。
2.  **倒数第二层保留了更多细节**:
    *   **L-1 层 (Penultimate Layer)** 的特征（图中红色的那些方块）通常包含了更丰富的**视觉细节、空间位置信息**。

![lecture_16, 页面 66](files/slides/CS231n/lecture_16.pdf#page=66)

LLaVA的全部架构如下：
首先，将图片传入到一个训练好的Vision Encoder (CLIP)中，提取出features。
之后将features传入到Linear Layer。这个Linear Layer will train to do s convert your CLIP representation into something  that the LLM can understand and make sense of.
Linear Layer生成的token给LLM即可。当然，这个LLM一般是已被训练好的。
![lecture_16, 页面 67](files/slides/CS231n/lecture_16.pdf#page=67)

---
#### Flamingo

Google的Flamingo架构做了一些改变。

图片经过Vision Encoder之后会被直接传入到LLM的每一层。文字被拎出来作为Processed Text传入。
Flamingo加入了两个部件，分别是Perceiver Resampler以及cross-attention layer(gated xattn-dense)。
其他的部件都是冻结的，训练的就是这两个部件。其表现出了很好的[泛化能力](files/slides/CS231n/lecture_16.pdf#page=82)
![lecture_16, 页面 69](files/slides/CS231n/lecture_16.pdf#page=73)

> Cross-Attention layer' purpose is to look at the image features and then decide what parts of the image features it wants to keep around, and what it thinks to be useful for the language model to know about.

加入这个层的主要目的是让模型也有能力调节图片在生成过程中的参与程度的大小。
![lecture_16, 页面 76](files/slides/CS231n/lecture_16.pdf#page=76)

Flamingo也有Masked机制。例如图片就没必要接触所有的Context，只需要接触他们各自对应的部分就好。
![lecture_16, 页面 79](files/slides/CS231n/lecture_16.pdf#page=79)

#### Molmo

虽然有很多蒸馏或是基于Open weights的模型也表现出了很好的多模态能力，但是这都源于闭源的OpenAI以及Gemini。
如果没有他们，开源社区(底下的LLaVA)就像路边，没有很好的Performance，蒸馏的这些模型也无从谈起。
![lecture_16, 页面 87](files/slides/CS231n/lecture_16.pdf#page=87)

Completely Open . Open Weights, Open Data, Open Code, Open Evals.
上课的兄弟小吹了一波他们lab的[Molmo](files/slides/CS231n/lecture_16.pdf#page=91)

他表明数据很重要(我也同意)，Molmo虽然只用了700000的Image-Text pairs训练，但他们的Image-Text pairs长这样：
![lecture_16, 页面 100](files/slides/CS231n/lecture_16.pdf#page=100)

## Segmentation Model

### Segment Anything Model (SAM)

![lecture_16, 页面 112](files/slides/CS231n/lecture_16.pdf#page=112)

> Masking model trained on a dataset of a huge number of categories. So How to get this?
> Model outputs mask of any objects that the user cares about. So How to know this?

想要很好地去分割图片中的事务？哪里来那么多高质量数据？
想要模型应该输出**用户关心**的那个物体(涉及歧义)？该如何让模型明白用户的Prompt？

基本架构如下。他还有个prompt encoder，我懒得写笔记了。
![lecture_16, 页面 121](files/slides/CS231n/lecture_16.pdf#page=121)

其实最关键的还是数据的标注，SAM的作者建立了一个有关很大的数据集SA-1B。


*   先训练一个初始版本的模型。人类标注员在标注时，模型会帮忙，加快了标注速度。标注好的数据又拿回去训练模型，让模型更聪明。
*   模型能力比较强时。对于简单的物体，模型直接自动标好；对于困难的、模糊的物体，才让人类去标。
*   模型已经大成时。给它海量的无标签图片，让它自己去把里面的所有物体都分割出来（生成 Mask）。SA-1B数据集大部分是由 SAM 模型自己生成的。[最终呈现的效果很好](files/slides/CS231n/lecture_16.pdf#page=125)。

![lecture_16, 页面 124](files/slides/CS231n/lecture_16.pdf#page=124)

---
## Chaining

### CuPL (CUstomized Prompts via Language models)

图像分类时，CLIP如何面对没有见过的东西呢？（比如图上的marimba)
这时，我们可以让LLM去描述我们需要分类的东西的特征（如下图），CLIP虽然没有见过特定的物品，但是见过这些特征，这时CLIP就可以分类的很好了。

![lecture_16, 页面 132](files/slides/CS231n/lecture_16.pdf#page=132)

### VisProg (visual programming)


假设我们想做一个任务，需要看两张图片并回答问题（Multi-image VQA）。我们可以专门训练一个大模型。但是模型的泛化能力可能很差：General to 2 images now, but not beyond that

 既然我们已经有了很多厉害的小模型（比如专门认图的 VQA 模型），为什么不把它们像积木一样拼起来？
我们可以利用 LLM把用户的自然语言指令，翻译成一段 **Python 代码**。让这段代码会去调用各种现成的视觉模型。这样就有很强的组合以及泛化能力。
![lecture_16, 页面 136](files/slides/CS231n/lecture_16.pdf#page=136)

如下是模型以及各种可调用的函数作为LLM生成代码的武器库。其实这么一看有点像agent里的思想啊。。。
![lecture_16, 页面 139](files/slides/CS231n/lecture_16.pdf#page=139)

