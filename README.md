# Mandrake [![Build Status](https://travis-ci.org/motns/mandrake.png)](https://travis-ci.org/motns/mandrake) [![Code Climate](https://codeclimate.com/github/motns/mandrake.png)](https://codeclimate.com/github/motns/mandrake) [![Dependency Status](https://gemnasium.com/motns/mandrake.png)](https://gemnasium.com/motns/mandrake) [![Coverage Status](https://coveralls.io/repos/motns/mandrake/badge.png?branch=master)](https://coveralls.io/r/motns/mandrake)

> NOTE: Work in progress! While it's generally stable, it's still missing most features.

## What it is

A simple data modeling framework, with additional functionality for validation, persistence and caching.

In many ways, Mandrake is like ActiveModel and DataMapper mashed together.
Internally it does a lot of things differently, but we tried to stay close to the conventions
and syntax used by those two frameworks, so it should feel familiar for the most part.


### So, another ODM framework?!

Well, sort of. The main difference is that the core data model, called a **Mandrake Model** has no
persistence functionality built into it. It's basically like an ActiveModel class, but with a
DataMapper-like syntax.

This layout makes it a better fit for describing and validating both database schemas, and arbitrary
data structures used in your app.


## Features

### Self-documenting

Our main goal is trasparency. You should be able to have a complete understanding
of the schema and behaviour of a model, purely by statically inspecting the model class.
This allows you to generate complete and up-to-date documentation at any time, a feature
that can be invaluable, especially in API applications.


### Efficient MongoDB ODM

As of this writing our primary data store is MongoDB, so the default persistence layer
is designed to work with that. There are additional methods for more efficient data
manipulation, allowing us to support the atomic modifiers in MongoDB (incrementing, set manipulation, etc.).

Also, we support field aliases by default, allowing you to store keys under a shorter name in the datastore,
while retaining long and descriptive names in the model.


### Simple and clean DSL

DataMapper (and similarly MongoMapper and MongoId) already have the core syntax nailed, so we
didn't stray too far from that path.


### Better validation

As of right now, all the popular Ruby ORM/ODM frameworks are based on **ActiveModel::Validations** in
some form or another. While it's an excellent validation framework, we felt that the simplified approach
for reporting validation errors wasn't a good fit for us.

Instead, we decided to port the custom validation framework from our API layer. It is a battle-tested system,
with more detailed (and machine-parsable) errors, and full introspection support for generating documentation.
Plus, thanks to Ruby, it now has a nice clean DSL slapped on top of it.



## What's missing

These are features that certain other frameworks currently support, but we specifically
decided not to. Many of these were dropped because they would potentially turn
Models into black boxes, where you won't know what they do until run time.


### No dynamic attributes

Any key you want to use, you'll have to declare up front using the schema definition
syntax.


### No block validators

Every validator has to be a named class, with a clearly defined list of input and output fields.
A block validator is essentially a black box, and therefore almost impossible to document properly.



## Usage

After installing the latest version of the mandrake gem:

    gem install mandrake

you can turn any Ruby Class into a Model by including Mandrake::Model:

    require 'mandrake'

    class User
      include Mandrake::Model
    end


### Schema Definition

As previously mentioned, the syntax for defining your keys looks almost exactly
like DataMapper (and MongoMapper/MongoId). To create a Model with a few keys:

    class User
      include Mandrake::Model

      key :name, :String, as: :n, required: true, length: 1..50
      key :email, :String, as: :e, required: true, format: :email
      key :age, :Integer, in: 1..150
    end

Breaking down the example above, the syntax for the **::key** method is:

    key key_name, Type, options_hash

* **key_name**: sets the name you will use to read/write this key in the Model
* **Type**: the name of the Type class for this key
* **options_hash**: additional options, mostly for defining validations.
The full list of available options is dependent on the chosen type class,
but some are always available:
  * **required**: Triggers the :Presence validator for this key
  * **as**: Used to define an alias the key will be saved under in the data store


> NOTE: This is just a basic overview; we'll be adding a proper wiki later on. For
the time being, read the Yard documentation [here](http://rdoc.info/github/motns/mandrake)
