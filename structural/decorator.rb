# frozen_string_literal: true

# 装饰模式是一种结构型设计模式， 允许你通过将对象放入包含行为的特殊封装对象中来为原对象绑定新的行为。

# TODO：开发一个将文本写入文件的程序，需要能根据选项控制是否在文本前加入行数、时间戳及其顺序

class Writer
  def initialize(path)
    @file = File.open(path, 'w')
  end

  def write_line(line)
    @file.print(line)
    @file.print("\n")
  end
end

class LineNumberWriter
  def initialize(writer)
    @writer = writer
    @line_number = 1
  end

  def write_line(line)
    @writer.write_line("#{@line_number}: #{line}")
    @line_number += 1
  end
end

class TimeStampingWriter
  def initialize(writer)
    @writer = writer
  end

  def write_line(line)
    @writer.write_line("#{Time.new} #{line}")
  end
end

options = { time_stamping: true, line_number: true }

writer = Writer.new('decorator.txt')

# 根据options顺序动态初始化装饰类链
options.each do |key, value|
  class_name = "#{key.to_s.split('_').map(&:capitalize).join('')}Writer"
  writer = Object.const_get(class_name).new(writer) if value
end

writer.write_line('Hello Decorator')
writer.write_line('This is a simply Composite Pattern')
writer.write_line('End')

# 2023-03-17 23:34:16 +0800 1: Hello Decorator
# 2023-03-17 23:34:16 +0800 2: This is a simply Composite Pattern
# 2023-03-17 23:34:16 +0800 3: End
