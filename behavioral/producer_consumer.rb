# frozen_string_literal: true

# 番外篇：生产者-消费者模型是指生产者和消费者通过一个缓冲区（通常是一个队列）的进行通讯。
# 生产者生产完数据之后不用等待消费者处理，直接放到缓冲区，消费者不找生产者要数据，而是直接从缓冲区里取，
# 这样既能够保持生产者和消费者的并发处理，也可以平衡生产者和消费者的处理能力。

# TODO：灵感来源于医院挂号候诊的叫号系统，病人通过取号机挂号后进入等待队列，并能在就诊室前的大屏幕看到号码或者姓名、等候人数、就诊室等信息。
# 一个科室（比如心血管科、牙科）可以有多个就诊室，就诊室有就诊功能，能同时接诊一个或多个病人

class Department
  attr_accessor :name
  attr_reader :rooms

  def initialize(name)
    @name = name
    @rooms = []
  end

  def add_room(room)
    rooms << room
  end

  def remove_room(room)
    rooms.delete(room)
  end

  def allocate_room
    rooms.find(&:waiting?)
  end

  def all_clean?
    rooms.all?(&:cleaning?)
  end
end

class Room
  attr_accessor :name
  attr_reader :consulting_patients, :consulting_patients_size

  def initialize(name, consulting_patients_size)
    @name = name
    @consulting_patients_size = consulting_patients_size
    @consulting_patients = []
    @mutex = Mutex.new
  end

  def receive(patient)
    @mutex.synchronize do
      return false unless consulting_patients.size < consulting_patients_size

      consulting_patients << patient
      consult(patient)
    end
  end

  # 异步调用就诊功能
  def consult(patient)
    Thread.new do
      # 随机0 ~ 20s的就诊时间
      sleep(rand(20))
      @mutex.synchronize do
        consulting_patients.delete(patient)
      end
    end
  end

  def waiting?
    @mutex.synchronize { consulting_patients.size < consulting_patients_size }
  end

  def cleaning?
    @mutex.synchronize { consulting_patients.size == 0 }
  end
end

class Patient
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

class RegistrationSystem
  attr_reader :department, :waiting_queue

  def initialize(department)
    @department = department
    @waiting_queue = []
    @mutex = Mutex.new
  end

  def start
    @state = 1
    @monitor ||= Thread.new {
      loop do
        @mutex.synchronize do
          if !waiting_queue.empty? && room = department.allocate_room
            room.receive(waiting_queue.shift)
            print
          end
        end
        sleep(1)
      end
    }
  end

  def end
    @state = 0
    sleep(1) until @mutex.synchronize { waiting_queue.empty? && department.all_clean? }
    @monitor.kill && @monitor = nil
  end

  def register(patient)
    return false unless @state == 1

    @mutex.synchronize do
      waiting_queue << patient
      print
    end
  end

  def print
    department.rooms.each do |room|
      puts "#{room.name}: #{room.consulting_patients.map(&:name)}"
    end
    puts "Waiting: #{waiting_queue.map(&:name)}"
  end
end

# 某日上午某医院的CT科室准备上班了，上班前值班医生准备设置挂号系统
# 今日有1号和2号两个就诊室，就诊室1号，2号都只能就诊一个病人
ct = Department.new('CT')
ct.add_room(Room.new('room_1', 1))
ct.add_room(Room.new('room_2', 1))

ct_system = RegistrationSystem.new(ct)

# 医生们准备好后打开了叫号系统
ct_system.start

# 陆续有病人在不同的时间来CT科室照CT
20.times.each do |num|
  patient = Patient.new("patient_#{num + 1}")
  ct_system.register(patient)
  sleep(rand(5))
end

# 关闭挂号系统后就不再接受挂号了，但仍需要把已经进入等待队列的病人就诊完
ct_system.end

# room_1: []
# room_2: []
# Waiting: ["patient_1"]
# room_1: []
# room_2: []
# Waiting: ["patient_1", "patient_2"]
# room_1: ["patient_1"]
# room_2: []
# Waiting: ["patient_2"]
# room_1: ["patient_1"]
# room_2: ["patient_2"]
# Waiting: []
# room_1: ["patient_1"]
# room_2: ["patient_2"]
# Waiting: ["patient_3"]
# room_1: ["patient_1"]
# room_2: ["patient_2"]
# Waiting: ["patient_3", "patient_4"]
# room_1: ["patient_1"]
# room_2: ["patient_2"]
# Waiting: ["patient_3", "patient_4", "patient_5"]
# room_1: ["patient_1"]
# room_2: ["patient_2"]
# Waiting: ["patient_3", "patient_4", "patient_5", "patient_6"]
# room_1: ["patient_1"]
# room_2: ["patient_2"]
# Waiting: ["patient_3", "patient_4", "patient_5", "patient_6", "patient_7"]
# room_1: ["patient_1"]
# room_2: ["patient_2"]
# Waiting: ["patient_3", "patient_4", "patient_5", "patient_6", "patient_7", "patient_8"]
# room_1: ["patient_3"]
# room_2: ["patient_2"]
# Waiting: ["patient_4", "patient_5", "patient_6", "patient_7", "patient_8"]
# room_1: ["patient_3"]
# room_2: ["patient_2"]
# Waiting: ["patient_4", "patient_5", "patient_6", "patient_7", "patient_8", "patient_9"]
# room_1: ["patient_3"]
# room_2: []
# Waiting: ["patient_4", "patient_5", "patient_6", "patient_7", "patient_8", "patient_9", "patient_10"]
# room_1: ["patient_3"]
# room_2: ["patient_4"]
# Waiting: ["patient_5", "patient_6", "patient_7", "patient_8", "patient_9", "patient_10"]
# room_1: ["patient_3"]
# room_2: ["patient_4"]
# Waiting: ["patient_5", "patient_6", "patient_7", "patient_8", "patient_9", "patient_10", "patient_11"]
# room_1: ["patient_3"]
# room_2: ["patient_4"]
# Waiting: ["patient_5", "patient_6", "patient_7", "patient_8", "patient_9", "patient_10", "patient_11", "patient_12"]
# room_1: ["patient_5"]
# room_2: ["patient_4"]
# Waiting: ["patient_6", "patient_7", "patient_8", "patient_9", "patient_10", "patient_11", "patient_12"]
# room_1: ["patient_5"]
# room_2: ["patient_4"]
# Waiting: ["patient_6", "patient_7", "patient_8", "patient_9", "patient_10", "patient_11", "patient_12", "patient_13"]
# room_1: ["patient_5"]
# room_2: ["patient_6"]
# Waiting: ["patient_7", "patient_8", "patient_9", "patient_10", "patient_11", "patient_12", "patient_13"]
# room_1: ["patient_5"]
# room_2: ["patient_6"]
# Waiting: ["patient_7", "patient_8", "patient_9", "patient_10", "patient_11", "patient_12", "patient_13", "patient_14"]
# room_1: ["patient_5"]
# room_2: ["patient_6"]
# Waiting: ["patient_7", "patient_8", "patient_9", "patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15"]
# room_1: ["patient_5"]
# room_2: ["patient_6"]
# Waiting: ["patient_7", "patient_8", "patient_9", "patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16"]
# room_1: ["patient_7"]
# room_2: ["patient_6"]
# Waiting: ["patient_8", "patient_9", "patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16"]
# room_1: ["patient_7"]
# room_2: ["patient_6"]
# Waiting: ["patient_8", "patient_9", "patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16", "patient_17"]
# room_1: ["patient_7"]
# room_2: ["patient_6"]
# Waiting: ["patient_8", "patient_9", "patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16", "patient_17", "patient_18"]
# room_1: ["patient_8"]
# room_2: ["patient_6"]
# Waiting: ["patient_9", "patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16", "patient_17", "patient_18"]
# room_1: []
# room_2: ["patient_6"]
# Waiting: ["patient_9", "patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16", "patient_17", "patient_18", "patient_19"]
# room_1: ["patient_9"]
# room_2: ["patient_6"]
# Waiting: ["patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16", "patient_17", "patient_18", "patient_19"]
# room_1: ["patient_9"]
# room_2: ["patient_6"]
# Waiting: ["patient_10", "patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16", "patient_17", "patient_18", "patient_19", "patient_20"]
# room_1: ["patient_9"]
# room_2: ["patient_10"]
# Waiting: ["patient_11", "patient_12", "patient_13", "patient_14", "patient_15", "patient_16", "patient_17", "patient_18", "patient_19", "patient_20"]
# room_1: ["patient_11"]
# room_2: ["patient_10"]
# Waiting: ["patient_12", "patient_13", "patient_14", "patient_15", "patient_16", "patient_17", "patient_18", "patient_19", "patient_20"]
# room_1: ["patient_11"]
# room_2: ["patient_12"]
# Waiting: ["patient_13", "patient_14", "patient_15", "patient_16", "patient_17", "patient_18", "patient_19", "patient_20"]
# room_1: ["patient_11"]
# room_2: ["patient_13"]
# Waiting: ["patient_14", "patient_15", "patient_16", "patient_17", "patient_18", "patient_19", "patient_20"]
# room_1: ["patient_14"]
# room_2: ["patient_13"]
# Waiting: ["patient_15", "patient_16", "patient_17", "patient_18", "patient_19", "patient_20"]
# room_1: ["patient_14"]
# room_2: ["patient_15"]
# Waiting: ["patient_16", "patient_17", "patient_18", "patient_19", "patient_20"]
# room_1: ["patient_16"]
# room_2: ["patient_15"]
# Waiting: ["patient_17", "patient_18", "patient_19", "patient_20"]
# room_1: ["patient_16"]
# room_2: ["patient_17"]
# Waiting: ["patient_18", "patient_19", "patient_20"]
# room_1: ["patient_18"]
# room_2: ["patient_17"]
# Waiting: ["patient_19", "patient_20"]
# room_1: ["patient_19"]
# room_2: ["patient_17"]
# Waiting: ["patient_20"]
# room_1: ["patient_19"]
# room_2: ["patient_20"]
# Waiting: []
