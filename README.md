# Mandrake

In simple terms, Mandrake is kind of like ActiveModel and DataMapper mashed together.
Except that it works in a totally different way internally. Don't freak out though,
we still try to adhere to as much of the ActiveModel and DataMapper conventions as we can,
so it will mostly feel familiar to use.

The model syntax is heavily inspired by (and is a mixture of) DataMapper, MongoMapper and MongoId, and while there is some overlap
in funcionality, it was designed to cover a slightly different set of use cases.

The main difference is that the core object, called a *Mandrake Model*, has no persistence functionality
built into it. The reason why is so we can use it to model and validate both our database schema, and
arbitrary data structures, like API inputs (more on this later).