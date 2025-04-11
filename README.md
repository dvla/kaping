# Dvla::Kaping

The Kaping! gem - an idiomatic way to create DSL openSearch definitions

## OpenSearch Query DSL
https://opensearch.org/docs/latest/query-dsl/

OpenSearch provides a search language called Query domain-specific language (Query DSL) that you can use to search for data. 
Query DSL is a flexible language with a JSON interface.

With query DSL, you need to specify a query in the query parameter of the search. One of the simplest searches in OpenSearch 
uses the match_all query, which matches all documents in an index:

```ruby
{"query":{"match_all":{}}}
```
Or you can search on a specific field for a specif value

```ruby
{
  "query": {
     "match_phrase": { "foo":"BAR"} }
  }
```

The real power of OpenSearch is you can combine multiple queries clauses to build complex search queries, the problem is they can be 
complex to construct so this gem looks to simplify the process.

## Query and filter context

A filter context asks - “Does the document match the query clause?” and returns matching documents 
i.e it's a binary answer

A query context asks - “How well does the document match the query clause?”, - also returns a relevance score
good for full-text searches

# How to use
Before you can use this Gem please ensure you can access your Opensearch instance. You may 
also need to configure and assume an AWS role depending on your environment

The **query builder** is the main feature of this gem, but there is also the additional facility to
set up a **client** to send the queries to OpeSearch. The client is also extended to enable a **search**,
so this will spin up a client, connect and post the query. Each of these features can be used independently
or as a package.

## Configuration

The gem makes use of the config settings to target the different environments, tables and aws settings.

The setting can be over-written by adding this line in your code

```ruby
DVLA::Kaping.configure { |attr| attr.yaml_override_path = './config/kaping.yml' }

```
The 'index' setting will control what environment to target

The 'result_size' setting determines how many records to be returned from the query, if you are doing a post query filtering 
code side then you should pump this value up.

```yml
kaping:
  host: <%= ENV['HOST'] || 'https://[path-to-service]' %>
  index: <%= ENV['INDEX'] || 'index-name'  %>
  result_size: 50
  log_level: <%= ENV['LOG_LEVEL'] || :debug %>

```
If you want to use the built-in client, and your OpenSearch instance is hosted in a Amazon VPC you will need to assume AWS permissions for access to run the queries.
there are two options, you can either use profile or environment

Profile will just pick up the credentials save in your specified shared credentials ini file at ~/.aws/credentials, 

```yml
  aws:
    #  to use a AWS profile config file then set to profile, otherwise environment settings will be used
    credential_type: profile
    account_id: ##########
    region: aws-region
    profile: PROFILE
    role: ROLE  
```

## Client

client.connect will get you a new connection to use for a search query. The client is fully configurable from the config settings.

```ruby
 client = DVLA::Kaping::AWSClient.new
 con = client.connect
  ```

  The client will need credentials which can be configured in the kaping.yml file or set as environment variables 

## Search
You can use the shortcut search facility, this will connect to a new client, all you need to do is supply the query to run

```ruby
body = DVLA::Kaping::Query.new('bool')
  body.filter.term('foo.bar', 'Valid').
    between('foo.dateOfBirth', '1958-08-21', '1970-08-21')

 response = DVLA::Kaping.search(body)
  ```

## Query building
A query can be built up with dot notation, but there are a few rules to follow. 

First get a new Kaping Query instance. If we want a new Boolean query then we set the type as bool. 
```ruby
my_query = DVLA::Kaping::Query.new('bool')
my_query.filter.term('foo.bar', 'Valid').
  between('foo.bar', '1958-08-21', '1970-08-21')

#  my_query.to_json will produce
'{"query":{"bool":{"filter":[{"term":{"foo":"Valid"}},{"range":{"foo.bar":{"gte":"1958-08-21","lte":"1970-08-21"}}}]}}}'

# we don't have to set the type for simple queries, the second parameter takes in key word arguments

my_query = DVLA::Kaping::Query.new('match_phrase', foo: 'bar')

#  my_query.to_json will produce
'{"query":{"match_phrase":{"foo":"bar"}}}'
```

We then set the context of the query, this can be in the form of a filter context or a query context parameter.

```ruby
my_query.filter
# or
my_query.match
```

Then you can start building up complex queries as required with the dot notation

Once you have your query defined you will then need to call to_json to build out the full
structure of the query from the ruby objects.

```ruby
my_json_query = my_query.to_json
```

## Code of Conduct

Everyone interacting in the Dvla::Kaping project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](./CODE_OF_CONDUCT.md).
