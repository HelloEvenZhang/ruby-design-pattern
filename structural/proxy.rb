# frozen_string_literal: true

# 代理模式是一种结构型设计模式， 让你能够提供对象的替代品或其占位符。 代理控制着对于原对象的访问， 并允许在将请求提交给对象前后进行一些处理。

# TODO：为ElasticSearch服务实现一个简易的代理类

require 'elasticsearch'

class ElasticSearchProxy
  def initialize(**options)
    @client = Elasticsearch::Client.new(
      host: options[:host] || 'localhost',
      port: options[:port] || '9200',
      log: options[:log] || true
    )
  end

  def index(index_name, **index_options)
    @client.index(index: index_name, **index_options)
  end

  def search(index_name, body)
    @client.search(index: index_name, body: body)
  end

  def get(index_name, id)
    @client.get(index: index_name, id: id)
  end

  def update(index_name, **update_options)
    @client.update(index: index_name, **update_options)
  end

  def delete(index_name, id)
    @client.delete(index: index_name, id: id)
  end

  def refresh_indices(index_name)
    @client.indices.refresh(index: index_name)
  end

  def cluster_health
    @client.cluster.health
  end
end

proxy = ElasticSearchProxy.new
proxy.index('my_index', id: 1, body: { title: 'My first ElasticSearch Proxy' })
proxy.search('my_index', { query: { match: { title: 'proxy' } } })

# PUT http://localhost:9200/my_index/_doc/1 [status:200, request:0.207s, query:n/a]
# {"title":"My first ElasticSearch Proxy"}
# {"_index":"my_index","_type":"_doc","_id":"1","_version":3,"result":"updated","_shards":{"total":2,"successful":1,"failed":0},"_seq_no":5,"_primary_term":1}

# GET http://localhost:9200/my_index/_search [status:200, request:0.760s, query:0.752s]
# {"query":{"match":{"title":"proxy"}}}
# {"took":752,"timed_out":false,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0},"hits":{"total":{"value":1,"relation":"eq"},"max_score":0.10536051,"hits":[{"_index":"my_index","_type":"_doc","_id":"1","_score":0.10536051,"_source":{"title":"My first ElasticSearch Proxy"}}]}}