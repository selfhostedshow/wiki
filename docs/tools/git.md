# Git

Git is version control software and is used to allow for collaborative projects. This wiki is developed and written using git.

## Our Analogy

In this article we will be using the example of writing a book to illustrate how Git is used. This is not a perfect analogy, but it is one that makes Git easily understandable. To make the analogy better, we can assume that at all times the book needs to be in a valid state in much the same way that source code must. After all while Git can be used on any files it is deigned to be used on source code.

Books start in an authors head. The author will then begin by writing down the first chapter. Over the course of days, weeks and months the author writes and revises over and over again, adding in new details, removing others, changing wordings, until finally the book is done. In theory, by tracking all the additions and deletions the author made to a book along the way and then applying them in the same order, you could recreate the book in its entirety. Not only could you recreate the finished book but you could reproduce the book at any point in its history as well. This is exactly what Git does, it tracks the changes that are made to files and allows for a history of a project as well.

## The Repository

A Project in the Git world is called a repository; often shortened to repo. We can think of the repository as the folder on the computer with an extensive history. This allows us to jump around in time. For example, you can see this wiki's repo on [GitHub](https://github.com/selfhostedshow/wiki).

## Branches

Branches are used for having multiple versions of the files with diverging timelines. Let's say, for a moment, that our fictional author wants to add a twist to his story. It is going to be a complicated change requiring him to go back and edit much of what he has already written, and he is not sure if he is going to want to keep this twist in. If we are using Git then the most logical thing to do is to create a branch in the repo; much like a copy the writer can make all of his changes and then decide if he wants to keep them. This use case alone does not warrant the use of these branching timelines[^1]. We see the real power of using branches when we start having multiple authors. One author can then be working on the twist in the story and the other can be working another part of the story. They can then merge the changes that both made into the final product.

[^1]: This particular problem could be solved by simply making a copy of the book and then decide which copy you want to go with.

### Example

Alice and Bob are writing a story together. Alice decides that they should have the mentor of the main character turn out to be a close relive. They want it to be hinted at throughout the book, but that requires changes throughout the book. They are not sure if the story is going to turn out well that way and it will be hard to separate out the changes that Alice makes if they both make them on the same version of the book. This is because there is no point in history of the book that all of Bob's changes will be made but none of Alice's. The solution is to use branches to keep track of the changes separately and then merge the changes if desired.

### Practical

By convention the main branch of a repo is called the `master` branch. It holds the latest accepted code. There are several other common branches `develop` (sometimes also called `dev`) is the other most common. Sometimes new branches are created for new features. For example, this article was prepared in its own branch until it was ready to go into the wiki.

You can check out the most current commit of a branch with `git checkout <branch-name>`.

## Commits

Git tracks changes to text based files and wraps those changes into packages called commits. These commits are the basic building blocks of a git repository. A branch is a list of commits. In each commit the changes made to the repo are explained by the author.

