# ⚡ Zaart!

  

zaart is a dead simple static site generator written in [dart programming language](https://dartlang.org).

you feed zaart with [markdown](https://daringfireball.net/projects/markdown/) files and it gives you back html files, that's it.

zaart also supports mustache template language that enables you to put some short

codes in your markdown files and have them expanded while building.

all keys defined in `zaart.json` can be accessed via mustache.

  

# ☢️ CAUTIONS!

zaart is in early development stage, use it at your own risk, you probably face some nasty bugs here an there.

  

# ✔️ How to install:

```sh

#> pub global activate zaart

```

  

# 🌎 Usage:

  

type in the command bellow in console to start a new site

```sh

#> zaart init --name [MY_SITE_NAME]

```

  

for more information type in:

```sh

#> zaart -h

```

or

```sh

#> zaart --help

```


see `TODO.md` file for a list of missing features