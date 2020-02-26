# Git

Git is version control software and is used to allow for collaborative projects.

## Our Analogy

In this article we illustrating with the example of writing a book. This is not a perfect analogy but it is one that easily understandable by most.

Books start in an authors head. The author will then begin by writing down the first chapter. Over the course of days, weeks and months the author writs and revises over and over again adding in new details removing others changing wordings until finally the book is done. In theory by tracking all of the additions and deletion the author made to a book along the way and then applying them in the same order you could recreate the book in it's entirety. Not only could you recreate the finished book but you could reproduce the book at any point in it's history as well. This is exactly what git does, it tracks the changes that are made to files and allows for a history of a project as well.

## The Repository

A Project in the git world is called a repository. We can think of the repository as the folder on the computer with an extensive history. We are able to jump around in time

## Branches

Branches are used for having multiple version of the files with diverging timelines. Lets say for a moment that are fictional author wants to add a twist to his story. It is going to be a complicated change requiring him to go back and edit much of what he has already written and he is not sure if he is going to want to keep in. If we are using Git then the most logic thing to go is create a branch in the repo much like a copy the writer can make all of his changes and then decide if he wants to keep them. This use case alone done not warrant the use of these branching timelines where we see there real power is when we start having multiple authors. One author can then be working on the twist in the story and the other can be working another part of the story. They can then merge the changes that both made into the final product.

### Example

Alice and Bob are writing a story together. Alice decides that they should have the mentor of the main character turn out to be a close relive. They want it to be hinted at through the book but that requires changes through out the book they are not sure if the story is going to turn out well that way and it will be hard to separate out the changes the Alice makes if they both make them on the same version of the book. this is because there is no point in history of the book that all of bobs changes will be made but none of Alice's. The solution Branches Keep track of the changes separately and then merge the changes if desired.

## Practical

By convention the main branch of a repo is called the `master` branch. It holds the latest accepted code. there are several other common branches `develop` is the other most common. You can checkout the most current commit of a branch with `git checkout <branch-name>`

## Commits

Git tracks changes to text based files and wraps those changes in to packages called commits. These commits are the basic building blocks of a git repository. A branch is a list of commits. 
