# frozen_string_literal: true

# 生成器是一种创建型设计模式，使你能够分步骤创建复杂对象。在Ruby中往往用来创建一个可能有许多配置选项的对象。

# TODO: 创建一个UserBuilder来完成User的初始化以及其配置选项

class User
  attr_accessor :first_name, :last_name, :birthday, :gender, :roles, :status, :username, :password

  def initialize(first_name=nil, last_name=nil, birthday=nil, gender=nil, roles=[], status=nil, username=nil, password=nil)
    @first_name = first_name
    @last_name = last_name
    @birthday = birthday
    @gender = gender
    @roles = roles
    @status = status
    @username = username
    @password = password
  end
end

class UserBuilder
  attr_reader :user

  def self.build
    builder = new
    yield builder
    builder.user
  end

  def initialize
    @user = User.new
  end

  def set_name(first_name, last_name)
    @user.first_name = first_name
    @user.last_name = last_name
  end

  def set_birthday(birthday)
    @user.birthday = Time.new(birthday)
  end

  def set_as_active
    @user.status = 'active'
  end

  def set_as_on_hold
    @user.status = 'on_hold'
  end

  def set_as_men
    @user.gender = 'm'
  end

  def set_as_women
    @user.gender = 'f'
  end

  def set_as_admin
    @user.roles = ['admin']
  end

  def set_login_credentials(username, password)
    @user.username = username
    @user.password = password
  end
end

# 如果不用UserBuilder初始化User就会像这样非常难看且繁琐
# User.new('John', 'Doe', Time.new('1999-03-02'), 'm', ['admin'], 'active', 'test@test.com')

user = UserBuilder.build do |builder|
  builder.set_name('Even', 'Zhang')
  builder.set_birthday('1999-08-02')
  builder.set_as_active
  builder.set_as_men
  builder.set_as_admin
  builder.set_login_credentials('evenzhang', 'abcdef')
end

p user
# #<User:0x000002218902b1e0 @first_name="Even", @last_name="Zhang", @birthday=1999-08-02 00:00:00 +0800, @gender="m", @roles=["admin"], @status="active", @username="evenzhang", @password="abcdef">
