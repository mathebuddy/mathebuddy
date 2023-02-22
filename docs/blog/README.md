## Steps to add a new blog entry:

1. Create a file `YYYY-MM-DD_TITLE.html` and replace `YYYY-DD-MM` by the
   current date and `TITLE` by an uppercase short title. The file contains
   the blog text in HTML. Use the existing files as example. HTML comments in the preamble `<!-- META -->` define meta data:

   | data        | description                                   |
   | ----------- | --------------------------------------------- |
   | date        | date of the blog entry in format `YYYY-DD-MM` |
   | title       | title of the block entry as HTML code         |
   | author-name | name of the author                            |
   | author-url  | website of the author (optional)              |
   | img         | image path (optional)                         |

   Bilingual text can be displayed as follows:

   - use `<span class="text-english"> MY HTML </span>` for English text
   - use `<span class="text-german"> MY HTML </span>` for German text

   For English-only texts, these span elements can be omitted.

2. Edit file `list.txt`: add a new line at the **beginning**.

   Format: Each line represents a filename of a blog entry.
