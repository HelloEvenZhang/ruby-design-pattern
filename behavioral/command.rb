# frozen_string_literal: true

# 命令是一种行为设计模式，它可将请求或简单操作转换为一个对象。

# TODO：实现一个安装程序，包含创建、复制、删除文件等操作，注意，这些操作未来可能会更新或更换顺序，且用户需要了解安装过程具体做了哪些操作
# 1. 声明带抽象执行方法的命令接口类
# 2. 声明实现命令接口的具体命令类，通过构造函数获取请求参数和对于实际接收者对象的引用
# 3. 实现一个类似组合模式的类，这个类负责保存命令的成员变量

require 'fileutils'

class Command
  attr_reader :description

  def initialize(description)
    @description = description
  end

  def execute
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

class CreateFile < Command
  def initialize(path, contents)
    super("Create file: #{path}")
    @path = path
    @contents = contents
  end

  def execute
    f = File.open(@path, "w")
    f.write(@contents)
    f.close
  end
end

class DeleteFile < Command
  def initialize(path)
    super("Delete file: #{path}")
    @path = path
  end

  def execute
    File.delete(@path)
  end
end

class CopyFile < Command
  def initialize(source, target)
    super("Copy file: #{source} to #{target}")
    @source = source
    @target = target
  end
  
  def execute
    FileUtils.copy(@source, @target)
  end
end

class Install < Command
  def initialize
    @commands = []
  end

  def add(command)
    @commands << command
  end

  def execute
    @commands.each(&:execute)
  end

  def description
    @commands.map(&:description).join(" => ")
  end
end

install = Install.new
install.add CreateFile.new('file1.txt', 'hello command')
install.add CopyFile.new('file1.txt', 'file2.txt')
install.add DeleteFile.new('file1.txt')
install.add DeleteFile.new('file2.txt')

install.execute
puts install.description

# Create file: file1.txt => Copy file: file1.txt to file2.txt => Delete file: file1.txt => Delete file: file2.txt