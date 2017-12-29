# The Working Standard for the minijava Project

## How to use an existing ocaml library


If you want to reuse an existing ocaml library. Start by installing it with opam. 

For example, to use colored terminal output you
use 

```sh
opam install ANSITerminal
```

Then you must inform ocamlbuild to use the ocamlfind tool :

```sh
ocamlbuild -use-ocamlfind Main.byte -- tests/UnFichierDeTest.java
```

et vous devez ajouter au fichier _tags la librarie en question par exemple :

```
true: package(ANSITerminal)
```