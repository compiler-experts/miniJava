# The Working Standard for the minijava Project


## How to work together

We use continous integration as collaboration mode, the reason is explained [here](continuous-integration-vs-working-seprately-for-weeks-and-then-making-a-huge-merge)

**Plese follow the following steps when adding new features**

1. `git checkout master` to position your self to the main branch (the master branch)
2. `git pull` to fetch latest commits from the default remote repository and merging them to your master branch
3. `git checkout -b <theme-feature>` create a new branch from the master branch, please pay attention to the branch name

    for example, if your are working on `lexcial analyse of inner classes` which is part of `le langage des classes`, your checkout command could be 
    ```sh
    git checkout -b classes-add-lexical-analyse-to-inner-classes
    ```
    plase note that branch name should in [kebab case](http://wiki.c2.com/?KebabCase)
4. Working on new features
5. Adding corresponding **test** in the directory `Evaluator`, make sure you have passed all test and not making any regressions with the shell script `./test`
6. `git commit -m <theme: feature>` your contributions

    for example, if your are working on `lexcial analyse of inner classes` which is part of `le langage des classes`, your commit message could be 
    ```sh
    git commit -m "classes: add lexcial analyse to inner classes"
    ```
7. `git push` to push your branch to the default remote repository
8. `git checkout master` to reposition your self to the main branch
9. `git pull` to refetch latest commits from the default remote repository and remerging them to your master branch
10. `git merge <theme-feature>` to merge your feature branch to the main branch
11. If your have confilts, plase follow the steps [here](https://help.github.com/articles/resolving-a-merge-conflict-using-the-command-line/)
12. `git push` to push the latest main branch, then others can develop new features based on your contributions

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

et vous devez ajouter au fichier _tags la librarie en question par exemple:

```
true: package(ANSITerminal)
```

## Continuous Integration Vs Working seprately for weeks and then making a huge merge

We have two collaboration mode, namely:
- adding features step by step, also merging them step by step, this is what we called Incremental development and continuous integration respectively
- working seperately, one team member adds a series of features at one time, then merging all seprate features together right before the deadline

It becomes obvious that the second collaboration mode has several disadvantages:
- working separately means you knows a little about what others are working on. It can be dangrous when we come to the merging step.
- making a huge merging is difficult and time-consuming compared continous integration. For example, we may have declared same varibles, then we need to rename them one by one in the merging step, or, we may have written reusable block of code, then we have to eliminate the duplication in the merging step.