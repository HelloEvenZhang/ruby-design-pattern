# frozen_string_literal: true

# 适配器模式是一种结构型设计模式， 它能使接口不兼容的对象能够相互合作。

# TODO：为一个文件加密类实现一个适配器，让它能为字符串加密

class Encryper
  def initialize(key)
    @key = key
  end

  def encrypt(reader, writer)
    key_index = 0
    while not reader.eof?
      clear_char = reader.getc
      encrypted_char = clear_char ^ @key[key_index]
      writer.putc(encrypted_char)
      key_index = (key_index + 1) % @key.size
    end
  end
end

class StringIOAdapter
  def initialize(string)
    @string = string
    @position = 0
  end

  def getc
    if @position >= @string.length
      raise EOFError
    end
    ch = @string[@position]
    @position += 1
    return ch
  end

  def eof?
    return @position >= @string.length
  end
end

reader = File.open('message.txt')
writer = File.open('message.encrypted', 'w')
encryper = Encryper.new('secret key')
encryper.encrypt(reader, writer)

encryper = Encryper.new('secret key')
reader = StringIOAdapter.new('We attack at dawn')
writer = File.open('out.txt', 'w')
encryper.encrypt(reader, writer)