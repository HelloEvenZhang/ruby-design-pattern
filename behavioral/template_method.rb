# frozen_string_literal: true

# 模版方法模式是一种行为设计模式，通过继承的方式实现算法的扩展。它在基类中定义了一个算法的框架，允许子类在不修改结构的情况下重写算法的特定步骤。

# TODO：开发一款分析公司文档的数据挖掘程序，用户需要向程序输入各种格式的文档（PDF、DOC、CSV...），程序则会试图从这些文件中抽取有意义的数据，并以统一格式的报表返回给用户。
# 1. 分析算法并分解为多个步骤：openFile => extractData => parseData => analyzeData => generateReport => closeFile
# 2. 定义基类，实现通用的步骤，不通用的步骤只需定义抽象方法等待子类重写，也可以在步骤间加上钩子方法
# 3. 定义子类，实现所有的抽象步骤

class DataMiner
  def initialize(path)
    @path = path
  end

  def generate_data_report
    open_file
    extract_data
    hook
    analyze_data
    generate_report
    close_file
  end

  def open_file
    puts "open #{@path}"
  end

  def extract_data
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def hook
  end

  def analyze_data
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def generate_report
    puts 'generate report with analyzed data'
  end

  def close_file
    puts 'close file'
  end
end

class PdfDataMiner < DataMiner
  def extract_data
    puts 'extract data from pdf file'
  end

  def analyze_data
    puts 'analyze pdf data'
  end
end

class CsvDataMiner < DataMiner
  def extract_data
    puts 'extract data from csv file'
  end

  def hook
    puts "csv hook"
  end

  def analyze_data
    puts 'analyze csv data'
  end
end

PdfDataMiner.new('file.pdf').generate_data_report
CsvDataMiner.new('file.csv').generate_data_report

# open file.pdf
# extract data from pdf file
# analyze pdf data
# generate report with analyzed data
# close file

# open file.csv
# extract data from csv file
# csv hook
# analyze csv data
# generate report with analyzed data
# close file