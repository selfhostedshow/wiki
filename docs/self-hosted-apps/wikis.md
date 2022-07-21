# Self Hosted Wikis
Choosing a wiki early on in a self-hosted setup is a great idea. Perhaps even before you have a dedicated server, having something in place to keep track of changes and create self-help pages for the home lab can help build the habit of writing things down before you wish you did.

As always, check out [awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted#wikis) but here are our favourites.

## Tiddlywiki
As the [Tiddlywiki](https://tiddlywiki.com/) website states that TiddlyWiki is "a non-linear personal web notebook". Because of the design of tiddlywiki, one could potentially argue it is better suited for those who like to write down a quick idea in order to come back later. It is able to be designed with contents, menus, and sub-menus.

The interface is a little utilitarian but it suits scatter brains rather well.

**Thoughts from the show:**  
_[timestamp](https://selfhosted.show/12): 20:00-22:35_

|Pros|Cons|
|----|----|
|Each "tiddler" (a note) can have one or more tags|Mentioned above: It's not the _prettiest_|
|Multiple tagged tiddlers can show up under multiple categories|Image uploads can be a pain. Upload as a sperate tiddler|
|Very lightweight application (40MiB of RAM at time of show)|Creating table of contents requires some manual work|
|Search is great||

## wiki.js
[Wiki.js](https://wiki.js.org/) is a somewhat more traditional wiki than Tiddlywiki in that it has dedicated pages organized by category, sub-category, etc. but with only one page per document that is linked. It also has a wonderful-looking interface that feels very modern.

**Thoughts from the show:**  
_[timestamp](https://selfhosted.show/12): 16:15-19:00_

!!!info "These thoughts are reflective of the show on 2020-02-13, some things have probably changed since then."

|Pros|Cons|
|----|----|
|Very Beautiful|Version 2 doesn't seem finished, lots of "coming soon" messages when clicking on something.|
|Search function works very well|"Site map coming soon" message.|
|GPL3|Unable to add multiple tags showing up in multiple sections|
|3 ways to host: Digital Ocean, AWS, self-hosted||

## BookStack
The idea concept of [BookStack](https://www.bookstackapp.com/) can be thought of combining the logical world of wikis, with their hierarchical structure, and the physical world of a library. In most self-hosted scenarios this tends to be the defacto-choice in wikis. Most who use BookStack enjoy its intuitive philosophy of a shelf being a generic subject or category, a book being a specific part of that shelf, and chapters within the book containing the most specific information.

**Thoughts from the show:**  
_[timestamp](https://selfhosted.show/12): 13:41-16:15_

|Pros|Cons|
|----|----|
|Lots of people consider BookStack the "gold standard" of wikis|Could be spending a lot of time figuring out the best way for information to fit this structure.|
|Divide notes into logical structure, which may not be applicable to all notes.|By default allowable upload file sizes are quite small. Instructions on how to modify this can be found in the [documentation](https://www.bookstackapp.com/docs/admin/upload-config/).|
|Example usage: Shelf for servers, book for hardware, and chapters for specific servers.||

## Honorable mention: GitBook
[GitBook](https://www.gitbook.com/)

**Thoughts from the show:**  
_[timestamp](https://selfhosted.show/12): 19:00-19:45_

Used for the docs at [linuxserver.io](https://docs.linuxserver.io/).

|Pros|Cons|
|----|----|
|Has "fuzzy search" (words within documents, not just titles)|Not open source|

## MkDocs
This wiki uses [MkDocs](https://www.mkdocs.org/)! What you _see_ is MkDocs using an theme called [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/), but underneath is MkDocs.  
MkDocs as mentioned is a static site generator, which means site changes must be edited, built, then deployed before changes can occur. Note the difference between this and a more traditional wiki would be that you could implement a change within the browser and on the page, save, and view the changes immediately on the public site.

These differences can be considered a pro or con depending on what you are looking for in a wiki.

**Thoughts from the show:**  
_[timestamp](https://selfhosted.show/12): 23:00-26:20_

Because it's git-based, git can be leveraged as a moderation tool via pull request model. Eg. Git blame who modified Chris Fisher's wiki page
