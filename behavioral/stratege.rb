# frozen_string_literal: true

# 策略模式是一种行为设计模式，通过组合的方式实现算法的扩展。它能让你定义一系列算法，并将每种算法分别放入独立的类中，以使算法的对象能够相互替换。

# Todo：开发一款动物园导游程序的导航功能，点击程序中的动物园地图上某个公共设施就能导航到目的地，但去目的地的方法不同会导致起点终点相同但路线不同（走路、乐园巴士、骑单车、驾车...），默认为走路。
# 1. 在上下文类中找到需要扩展的算法代码
# 2. 为每个算法实现对应的类，并提供同一个方法完成算法目标。如果有共同的代码，可以为这些算法类实现一个共同的超类，没有的话只需要像鸭子类型一样，保证它们有相同的调用方法即可
# 3. 在上下文类中添加一个成员变量用于保存对于策略对象的引用，然后提供设置器以修改该成员变量
# 4. 客户端将上下文类与相应策略进行关联，使上下文可以预期的方式完成其主要工作

class Navigator
  attr_accessor :strategy

  def initialize(current_location, destination, strategy = WalkingStrategy.new)
    @current_location = current_location
    @destination = destination
    @strategy = strategy
  end

  def build_route
    puts "Now, you are at #{@current_location}"
    @strategy.build_route(@current_location, @destination)
    puts "Finally, you will be able to reach #{@destination}"
  end
end

class WalkingStrategy
  def build_route(current_location, destination)
    puts "#{current_location}...Walking to...#{destination}"
  end
end

class DriveStrategy
  def build_route(current_location, destination)
    puts "#{current_location}...Driving to...#{destination}"
  end
end

zoo_navigator = Navigator.new("A", "B")
zoo_navigator.build_route

zoo_navigator.strategy = DriveStrategy.new
zoo_navigator.build_route

# Now, you are at A
# A...Walking to...B
# Finally, you will be able to reach B

# Now, you are at A
# A...Driving to...B
# Finally, you will be able to reach B
