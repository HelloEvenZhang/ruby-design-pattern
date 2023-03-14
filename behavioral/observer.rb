# frozen_string_literal: true

# 观察者模式是一种行为设计模式，允许你定义一种订阅机制，可在对象事件发生时通知多个 “观察” 该对象的其他对象。

# Todo：为商店开发一个商品到货提醒程序，当商品到货后，发邮件提醒订阅的顾客商品到货了
# 1. 将业务逻辑中变更时需要提醒的主体作为发布者，被提醒的作为观察者
# 2. 定义观察者类，实现一个被提醒时触发的update方法
# 3. 定义发布者类，并在类中实现可添加和删除观察者对象，实现通知方法，每次发布者发生了重要事件时都必须通知所有的订阅者
# 4. 绝大部分观察者需要一些与事件相关的上下文数据，这些数据可作为update方法的参数来传递，当然，发布者也可以将自身传出去
# 5. 客户端需要生成所需的全部观察者，并在相应的发布者处完成添加操作

require 'observer'

class Product
  include Observable

  def initialize
    @state = 'In Stock'
  end

  def state
    puts @state
  end

  def out_of_stock
    return false if @state == 'Out Of Stock'

    @state = 'Out Of Stock'
    true
  end
  
  def in_stock
    return false if @state == 'In Stock'

    @state = 'In Stock'
    changed
    notify_observers(@state)
    true
  end
end

class Customer
  def initialize(name)
    @name = name
  end

  def update(state)
    puts "Send email to #{@name}: Product already #{state}."
  end
end

product = Product.new
product.out_of_stock
product.state

customer_a = Customer.new('Customer A')
customer_b = Customer.new('Customer B')
product.add_observer(customer_a)
product.add_observer(customer_b)

product.in_stock

# Out Of Stock
# Send email to Customer A: Product already In Stock.
# Send email to Customer B: Product already In Stock.
