Steps to add a new blog entry:
------------------------------

1. Create a file ``YYYY-MM-DD_TITLE.md`` and replace ``YYYY-DD-MM`` by the 
   current  date and ``TITLE`` by an uppercase short title. The file contains
   the blog text in Markdown. Use the existing files as example.
   
   ```
   ## Title of Blog Post
   *2022-08-08 [Full Author name](Author website URL)*
   
   Some Text here...
   
   - a bullet point
   - another bullet point
   ```

2. Edit file ``list.txt``: add a new line at the beginning. 

   Format: ``FILE`` or ``FILE # IMAGE_PATH``. 
   - ``FILE`` is the filename of step 1.
   - ``IMAGE_PATH`` is a file path relative to the repository.
