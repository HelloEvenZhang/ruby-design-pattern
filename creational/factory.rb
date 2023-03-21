# frozen_string_literal: true

# 工厂方法是一种创建型设计模式，解决了在不指定具体类的情况下创建产品对象的问题。

# TODO: 模仿ActiveRecord中创建数据库连接的方式，为mysql,sqlite3,postgresql创建数据库连接

class AbstractAdapter
  def initialize(connection, config = {})
    @connection = connection
    @config = config
  end
end

class MysqlAdapter < AbstractAdapter
  def self.new_client
    p 'connecting mysql...'
  end

  def initialize(connection, connection_options, config)
    super(connection, config)

    p "init mysql database"
  end
end

class Sqlite3Adapter < AbstractAdapter
  def self.new_client
    p 'connecting sqlite3...'
  end

  def initialize(connection, connection_options, config)
    super(connection, config)

    p "init sqlite3 database"
  end
end

class PostgresqlAdapter < AbstractAdapter
  def self.new_client
    p 'connecting postgresql...'
  end

  def initialize(connection, connection_options, config)
    super(connection, config)

    p "init postgresql database"
  end
end

module ConnectionHandling
  def mysql_connection(config)
    mysql_options = {}
    MysqlAdapter.new(MysqlAdapter.new_client, mysql_options, config)
  end

  def sqlite3_connection(config)
    sqlite3_options = {}
    Sqlite3Adapter.new(Sqlite3Adapter.new_client, sqlite3_options, config)
  end

  def postgresql_connection(config)
    postgresql_options = {}
    PostgresqlAdapter.new(PostgresqlAdapter.new_client, postgresql_options,config)
  end
end

class Base
  extend ConnectionHandling
end

adapter = 'mysql'
method_name = "#{adapter}_connection"
Base.send(method_name, {})

# "connecting mysql..."
# "init mysql database"
