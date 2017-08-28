---
title: Understand Hakyll
author: Yun Hao
tag:
---

It's nice to understand how the original template works. With no a priori
knowledge of Haskell. I learn it in the hard way.

- - - - - - - - - - 

The `site.hs` contains the `main` function,
this is the place where an *I/O action* is executed. This is explained in

* http://learnyouahaskell.com/input-and-output#hello-world

> So, when will an I/O action be performed? Well, this is where main comes in.
> An I/O action will be performed when we give it a name of main and then
> run our program.

- - - - - - - - - - 

The main function is defined as 

```haskell
main = hakyll $ do
   SOMETHING
```

`hakyll` is a *function* and it has type

```haskell
hakyll :: Rules a -> IO ()
```

meaning that it takes something of type `Rules a`, and result in something
of type `IO ()`.

The type `IO ()` is explained in the previous link. Basically,
it means *an I/O action that results in the empty tupe `()`*.

Now what is `Rules a`? `Rules` is something called a *type constructor*,
it is explained in

* http://learnyouahaskell.com/making-our-own-types-and-typeclasses#type-parameters

`Rules a` is defined in `Hakyll.Core.Rules.Internal`.
It's hard for me to understand it for now, so let us put it aside.
But it is important to understand that if the *type variable* `a`
is `SOMETYPE`, then we will get a type `Rules SOMETYPE`.

`do` is explained also in the fisrt link. It is a syntax to put
some I/O actions together into one. So the whole indented block is something
of type `IO ?`. Now I am not sure what is the type of the result of all these
I/O actions. It should be the empty tupe `()`, but that is not important for
now. It's only important to know the whole stuff is an I/O action that will
give some result ?.

Now the dolar sign, it is explained in 

* http://learnyouahaskell.com/higher-order-functions#function-application

But a little bit confusing in the begining. A better reference is

* https://stackoverflow.com/questions/940382/haskell-difference-between-dot-and-dollar-sign

Basically, we can treat it a separator for now. Everything after the dollar sign
will be treat as one thing. The it is easy to understand: codes after `$` are
`do SOMETHING`, hence of type `IO ?` as explained above. So the action,
after execution, give `?`. So '?' becomes the value of the type variable `a` in
`Rules a`, i.e., we are feeding the function `hakyll` with variable of type
`Rules ?`. (As I guess `?` should be `()`, it should be `Rules ()'. Anyway,
it's enough to understand it to this extent for now.) 

- - - - - - - - - - 

In the `do` block. We have `match` function. It has type

```haskell
match :: Pattern -> Rules () -> Rules ()
```

So it has two variables, the first one is of type `Pattern`,
and the second one is of type `Rules ()`. The value of match function is of
type `Rules ()`.

So the codes

```haskell
match "images/*" $ do
    route   idRoute
    compile copyFileCompile
```

means that we give the `"images/*"` as the first varible with type `Patter`,
and `do SOMETHING` as the second variable with type `Rules ()`.

Now what will `do`? The first thing is `route idRoute`. The function `route`
is defined in `Hakyll.Core.Routes`. It has type

```haskell
route :: Routes -> Rules ()
```

So it takes something of type `Routes` and gives a value of type `Rules ()`.
Of course `idRoute` is of type `Routes`.

The next function `compile` is of type

```haskell
compile
  :: (Writable a, Data.Typeable.Internal.Typeable a,
      binary-0.8.3.0:Data.Binary.Class.Binary a) =>
     Compiler (Item a) -> Rules ()
```

This is a little bit complicated, but not that much.

> Everything before the => symbol is called a *class constraint* 
(seems also called a *type constriant*)

as explained in

* http://learnyouahaskell.com/types-and-typeclasses#typeclasses-101

So the `compile` function has one variable of type `Compiler (Item a)`, and
one value of type `Rules ()`. What is more, the type variable `a` has to have
type belongs to *typeclassess* `Writable`, and `Data.Typeable.Internal.Typeable`,
`binary-0.8.3.0:Data.Binary.Class.Binary` ---
what are these are not that important. Of course, `copyFileCompiler`
is the varialbe that has type `Compiler (Item a)`. Acutually, we have

```haskell
copyFileCompiler :: Compiler (Item CopyFile)
'''

Now we know the `do SOMTHING` in this first small block returns something of
type `Rules ()`, which is the result of the *last* I/O action in the `do` list.
This `do SOMETHING` as a whole, serves as the second variable of the function
`match`.

Finally the function `match` returns its value of tpye `Rules ()`.


The next small block

```haskell
match "css/*" $ do
    route   idRoute
    compile compressCssCompiler
```
is similar.

- - - - - - - - - - 

Continue.

```haskell
match (fromList ["about.rst", "contact.markdown"]) $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls
```

Only need to understand what will `do`.

The variable of the route is the value of `setExtension "html"`. The function
`setExtension` has type:

```haskell
setExtension :: String -> Routes
```

The line

```haskell
route   $ setExtension "html"
``` 

can be replaced by

```haskell
route . setExtension "html"
```

where `.` is the composition of fuctions. It is explained in

* http://learnyouahaskell.com/higher-order-functions#composition

as well as a link given above.

The variable of `compile` is

```haskell
pandocCompiler
    >>= loadAndApplyTemplate "templates/default.html" defaultContext
    >>= relativizeUrls
```

`pandocCompiler` has type

```hasekll
pandocCompiler :: Compiler (Item String)
```




- - - - - - - - - - 
- - - - - - - - - - 
- - - - - - - - - - 
- - - - - - - - - - 
- - - - - - - - - - 
- - - - - - - - - - 
- - - - - - - - - - 
- - - - - - - - - - 




