# pytorch 线性回归[^1][^2]

我们将根据带有噪声的线性模型构造一个人造数据集。 我们的任务是使用这个有限样本的数据集来恢复这个模型的参数。


### 生成数据集

我们使用线性模型参数$\mathbf{w} = [2, -3.4]^\top$、$b=4.2$ 和噪声项$\epsilon$生成数据集及其标签：


$$\mathbf{y}= \mathbf{X} \mathbf{w} + b + \mathbf\epsilon.$$
下面的代码生成合成数据集：
```python
# normal(arg1,arg2,arg3) arg1为均值，arg2为标准差，arg3为形状
# reshape参数取-1意味着让 PyTorch 自动计算这个维度的大小
# 这里会让y从(1000,)->(1000,1)

def synthetic_data(w, b, num_examples):  #@save
    """生成y=Xw+b+噪声"""
    X = torch.normal(0, 1, (num_examples, len(w)))
    y = torch.matmul(X, w) + b
    y += torch.normal(0, 0.01, y.shape)
    return X, y.reshape(-1, 1)
	
true_w = torch.tensor([2, -3.4])
true_b = 4.2
features, labels = synthetic_data(true_w, true_b, 1000)

```

### 读取数据集

```python
# TensorDataset接收一个或多个第一个维度相同的张量，并将它们打包成一个数据集对象。
# DataLoader为PyTorch 中用于加载数据的核心工具
# shuffle参数指是否随机打乱

def load_array(data_arrays, batch_size, is_train=True):  #@save
    """构造一个PyTorch数据迭代器"""
    dataset = data.TensorDataset(*data_arrays)
    return data.DataLoader(dataset, batch_size, shuffle=is_train)

batch_size = 10
data_iter = load_array((features, labels), batch_size)

```

### 定义模型及参数

对于标准深度学习模型，我们可以使用框架的预定义好的层。这使我们只需关注使用哪些层来构造模型，而不必关注层的实现细节。

我们首先定义一个模型变量`net`，它是一个`Sequential`类的实例。 `Sequential`类将多个层串联在一起。 

当给定输入数据时，`Sequential`实例将数据传入到第一层， 然后将第一层的输出作为第二层的输入，以此类推。

```python
# nn是神经网络的缩写
# nn.Linear定义线性层，即(W^T+b)
# Linear(arg1,arg2) arg1为输入特征的数量，arg2为输出特征的数量

from torch import nn

net = nn.Sequential(nn.Linear(2, 1))

# net[0]选择网络中的第一个层
# net[0].weight/bias获取权重和偏置
# .data用来避免autograd

net[0].weight.data.normal_(0, 0.01)
net[0].bias.data.fill_(0)
```


> [!question] 手动实现
>
>``` python
> # 参数：
>w = torch.normal(0, 0.01, size=(2,1), requires_grad=True)
>b = torch.zeros(1, requires_grad=True)
>
> def linreg(X, w, b):  #@save
>    """线性回归模型"""
>    return torch.matmul(X, w) + b
>```
### 定义损失函数及优化算法

小批量随机梯度下降算法是一种优化神经网络的标准工具， PyTorch在`optim`模块中实现了该算法的许多变种。

当我们实例化一个`SGD`实例时，我们要指定优化的参数 （可通过`net.parameters()`从我们的模型中获得）以及优化算法所需的超参数字典。 

小批量随机梯度下降只需要设置`lr`值(学习率)，这里设置为0.03。

```python
# 计算均方误差使用的是MSELoss类,它默认返回所有样本损失的平均值
loss = nn.MSELoss()
trainer = torch.optim.SGD(net.parameters(), lr=0.03)
```

> [!question] 手动实现
>
>``` python
> 	
>def squared_loss(y_hat, y):  #@save
>    """均方损失"""
>    return (y_hat - y.reshape(y_hat.shape)) ** 2 / 2
>
> def sgd(params, lr, batch_size):  #@save
>    """小批量随机梯度下降"""
>    with torch.no_grad(): # 避免影响计算图
>        for param in params:
>            param -= lr * param.grad / batch_size
>            param.grad.zero_()
>```

### 训练


通过深度学习框架的高级API来实现我们的模型只需要相对较少的代码。 

我们不必单独分配参数、不必定义我们的损失函数，也不必手动实现小批量随机梯度下降。 当我们需要更复杂的模型时，高级API的优势将大大增加。


```python
num_epochs = 3
for epoch in range(num_epochs):
    for X, y in data_iter:
        l = loss(net(X) ,y) # net(X)进行前向传播计算
        trainer.zero_grad() # 清除所有参数在上一次计算中累积的梯度
        l.backward()
        trainer.step()      # 更新参数
    l = loss(net(features), labels)
    print(f'epoch {epoch + 1}, loss {l:f}')
```




[^1]: https://zh-v2.d2l.ai/chapter_linear-networks/linear-regression-scratch.html#id8

[^2]: https://zh-v2.d2l.ai/chapter_linear-networks/linear-regression-concise.html#id2

[^3]: https://zh-v2.d2l.ai/chapter_linear-networks/linear-regression-scratch.html#id3
