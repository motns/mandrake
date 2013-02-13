# Mandrake

## What is it

A data modeling framework, with additional functionality for validation, persistence and caching.

In simple terms, Mandrake is kind of like ActiveModel and DataMapper mashed together.
Internally it does a lot of things differently, but we tried to stay close to the conventions
and syntax used by those two frameworks, so it should feel familiar for the most part.


### So, another ORM framework?!

Well, sort of. The main difference is that the core data model, called a **Mandrake Model** has no
persistence functionality built into it. It's basically like an ActiveModel class, but with a
DataMapper-like syntax.

The reason why went for this structure, is so that we can use it to define and validate both our database schema,
and other arbitrary data structures (more on this later).


## Goals

### Better validation

Pretty much all the Ruby ORM frameworks are at least loosely based on **ActiveModel::Validations**.
While this is an excellent framework for validation, and very easy to use and extend,
there were areas where we felt it wasn't a good fit for us. Modifying ActiveModel::Validations
would have been a lot of work, and would've defeated the purpose of us using it in the first place.
Intead, we wrote our own thing (in fact, this is a port of the validation system from our current API app).

Our main problem with ActiveModel was in the way feedback is given on validation failures. The approach of having a list of error strings
for each field works great in web application frameworks like Rails (where ActiveModel originated from), but in
an API environment you want to be able to give better, more detailed, and more importantly machine-parsable responses.

Read the section on Validation to see how we achieve this.