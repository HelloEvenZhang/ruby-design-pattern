# frozen_string_literal: true

# 迭代器模式是一种行为设计模式，让你能在不暴露集合底层表现形式（列表、 栈和树等）的情况下遍历集合中所有的元素。

# TODO: 为组合模式中树结构的包裹程序实现迭代功能，让包裹可以被遍历获得包裹中所有产品的name
# 1. 首先要确定集合类和集合元素类
# 2. 确定集合类遍历集合元素类的算法
# 3. 为集合类实现each方法，必要时可以为集合元素类实现<=>方法（Ruby中已实现了Enumerable，实现each接口就行）

module Compositeable
  attr_reader :childrens
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
  include Enumerable

  # 默认使用深度优先算法
  def each(&block)
    return unless defined? @childrens

    @childrens.each do |children|
      if children.composite?
        children.each(&block)
      else
        yield children
      end
    end
  end

  # 广度优先算法
  def breadth_each(&block)
    return unless defined? @childrens

    queue = []
    queue << self

    while !queue.empty? do
      children = queue.shift

      if children.composite?
        children.childrens.each do |child|
          queue << child
        end
        next
      end

      yield children
    end
  end
end

class Product
  include Leafable

  attr_reader :name

  def initialize(name)
    @name = name
  end
end

#        p
#      /   \
#     p1    A
#    /  \
#   p2   B
#  /  \
# C    D

p = Package.new
p1 = Package.new
p2 = Package.new

product_a = Product.new("A")
product_b = Product.new("B")
product_c = Product.new("C")
product_d = Product.new("D")

p.add p1
p.add product_a
p1.add p2
p1.add product_b
p2.add product_c
p2.add product_d

p.each { |product| puts product.name }
p.breadth_each { |product| puts product.name }

# C
# D
# B
# A
# A
# B
# C
# D