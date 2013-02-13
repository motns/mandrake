# Mandrake

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


## What's hot

### Self-documenting

Our primary principle is trasparency. You should be able to have a complete understanding
of the schema and behaviour of a model, purely by statically inspecting the model class.
This allows you to generate complete and up-to-date documentation at any time, a feature
which is invaluable especially in API applications.


### Efficient MongoDB ODM

As of this writing our primary data store is MongoDB, so the default persistence layer
is designed to work with that. Also, there are additional methods for more efficient data
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
Plus, thanks to Ruby, it has a nice clean DSL slapped on top of it.



## What's not

These are features that certain other frameworks currently support, but we specifically
decided not to. Many of these were dropped because they would otherwise violate our
primary principle.


### No dynamic attributes

Any key you want to use, you'll have to declare up front using the schema definition
syntax.


### No block validators

Every validator has to be a named class, with a clearly defined list of input and output fields.
Block validators are essentially a black box, and therefore conflict with our primary principle.


### No relationships

While we support the arbitrary nesting of other Models inside a Model class ("embedded documents" in MongoDB lingo),
we do not have any dedicated methods for describing the relationship between models.

