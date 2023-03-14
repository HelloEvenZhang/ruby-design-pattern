# frozen_string_literal: true

# 组合模式是一种结构型设计模式，你可以使用它将对象组合成树状结构，并且能像使用独立对象一样使用它们。

# Todo：开发一个计算包裹总价格的程序，注意，包裹中可以同时含有包裹和产品
# 1. 确保应用的核心模型能够以树状结构表示，尝试将其分解为简单元素和容器。记住，容器必须能够同时包含简单元素和其他容器。
# 2. 创建一个叶节点类表示简单元素
# 3. 创建一个容器类表示复杂元素，创建一个数组成员变量来存储对于其子元素的引用，并定义添加和删除子元素的方法
# 4. 可以选择为所有类定义parent元素来访问父节点，父节点添加和删除子元素要处理好子元素的parent参数

module Compositeable
  attr_accessor :parent
  
  def add(children)
    @childrens = [] unless defined? @childrens
    @childrens.append children
    children.parent = self
  end

  def delete(children)
    @childrens.delete children if defined? @childrens
    children.parent = nil
  end

  def composite?
    true
  end
end

module Leafable
  attr_accessor :parent

  def composite?
    false
  end
end

class Package
  include Compositeable

  def total
    return 0 unless defined? @childrens

    @childrens.map(&:total).sum
  end
end

class Product
  include Leafable

  def initialize(price)
    @price = price
  end

  def total
    @price
  end
end

p = Package.new
p1 = Package.new
p2 = Package.new

product1 = Product.new(10)
product2 = Product.new(20)
product3 = Product.new(30)
product4 = Product.new(40)
p.add(p1)
p.add(p2)
p.add(product1)
p1.add(product2)
p1.add(product3)
p2.add(product4)

p p.total
p p1.total
p p2.total

# 100
# 50
# 40