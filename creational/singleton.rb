# frozen_string_literal: true

# 单例是一种创建型设计模式 让你能够保证一个类只有一个实例，并提供一个访问该实例的全局节点。

# TODO：制作一个单例的日志工具类，通过控制LEVEL的级别，就可以自由地控制打印的内容

require 'singleton'

class Logger
  include Singleton

  DEBUG = 0
  INFO = 1
  ERROR = 2
  NOTHING = 3

  LEVEL = DEBUG

  def debug(message)
    puts message if LEVEL <= DEBUG
  end

  def info(message)
    puts message if LEVEL <= INFO
  end

  def error(message)
    puts message if LEVEL <= ERROR
  end
end

logger = Logger.instance
logger.debug('...DEBUG...')
logger.info('...INFO...')
logger.error('...ERROR...')

# ...DEBUG...
# ...INFO...
# ...ERROR...
