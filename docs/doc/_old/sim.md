<!-- Mathe:Buddy Simulator -->

---

**NOTE**

- This installation guide is in work-in-progress state.

---

---

**NOTE**

- If you installed mathe:buddy simulator before 2023-01-19, then run `git stash` and `git pull` in Terminal, right before running `python3 server.py`. This must be done only once.

---

We provide a web-based simulation environment for the `mathe:buddy` app.

![](img/screenshot.png)

# Outline

Implementation is ongoing. We plan to release ...

1. An interactive _Integrated Development Environment (IDE)_ that runs in the browser without any software dependencies [Release is planned for second half of 2023].
2. Plugins for _Visual Studio Code_ [Release in the market place is planned for first quarter of 2023].

By now, you have to run the simulator on a local computer. Installation and usage might be challenging - if you are not a developer, you should wait for the above mentioned releases...

# Committing Courses

Yau are encouraged to use and test our toolchain! We will later allow anyone to create custom math-courses. .. BE PATIENT FOR THAT!

# Installation

Make sure you got `git`, `python3`, `npm`, `node` and `pandoc` installed on your system.

- Debian-based Linux:
  ```
  sudo apt install git python3 nodejs npm pandoc
  ```
- macOS:
  First install `homebrew` package manager as described on [https://brew.sh](https://brew.sh). Then run the following commands in a terminal window:
  ```
  brew install git python3 node pandoc
  ```

You now need to clone three _mathe:buddy_ repositories. Replace `YOUR_FAVORITE_DIRECTORY` by a local directory on your disk.

> TIP: use [GitHub Desktop](https://desktop.github.com) to clone the repositories (refer to the end of this document).

```
cd YOUR_FAVORITE_DIRECTORY
git clone https://github.com/mathebuddy/mathebuddy-simulator.git
git clone https://github.com/mathebuddy/mathebuddy-math-runtime.git
git clone https://github.com/mathebuddy/mathebuddy-compiler.git
git clone https://github.com/mathebuddy/mathebuddy-smpl.git
git clone https://github.com/mathebuddy/mathebuddy-public-courses.git
```

Developers of the core team should use a SSH key pair; see
[https://docs.github.com/en/authentication/connecting-to-github-with-ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh); and also clone the private repository:

```
cd YOUR_FAVORITE_DIRECTORY
git clone git@github.com:mathebuddy/mathebuddy-simulator.git
git clone git@github.com:mathebuddy/mathebuddy-math-runtime.git
git clone git@github.com:mathebuddy/mathebuddy-compiler.git
git clone git@github.com:mathebuddy/mathebuddy-smpl.git
git clone git@github.com:mathebuddy/mathebuddy-public-courses.git
git clone git@github.com:mathebuddy/mathebuddy-private-courses.git
```

> Remark: it is essential that all three repositories are located next to each other!

> WARNING: Never(!!) clone to iCloud / GoogleDrive / OneDrive / NextCloud / Sciebo / ...!

# Usage

Change to directory `mathebuddy-simulator`:

```
cd mathebuddy-simulator
```

> Tip: in macOS you can open the directory `mathebuddy-simulator` in the Finder and then open a terminal window in that location. Open `[Finder]` $\to$ `[Services]` $\to$ `[New Terminal at Folder]`.

Run `server.py`:

```
python3 server.py
```

The following Read-Eval-Print-Loop (REPL) is provided.
Choose a number and press `[ENTER]`.

1. **`update`** [MUST be run first]

- updates the repositories to the latest revisions on GitHub
- installs the `npm` packages from `package.json` and compiles the sources.

2. **`make playground`** [RECOMMENDED!!]

- creates a playground directory in `mathebuddy-public-courses`, which is NOT synced.

3. **`start web server`**

- starts a web server at port 8314. Open [http://localhost:8314](http://localhost:8314) in your favorite browser. You should see the contents of screenshot above ("hello world" will be shown later!)

- Select a file from the dropdown menu. All files with suffix `*.mbl` (mathe:buddy language) from repository `mathebuddy-public-courses` are listed. Open `../mathebuddy-public-courses/demo-basic/hello.mbl` for a hello world example. The compiler is run automatically and the simulator renders the result.

- Use radio buttons `input`, `JSON` and `HTML` to show intermediate results:

  - `input` is the source code of the opened `*.mbl` file
  - `JSON` shows the output of the compiler. This intermediate language is both used in the simulator, as well as the app.
  - `HTML` shows the HTML-code that is shown in the simulator. This feature is only intended for debugging purposes.

- Button `refresh file list` updates the file list in the dropdown menu. Should be used in case that you rename / create a file in `mathebuddy-public-courses`.

- Button `run` updates the simulator. Should be used after editing some of the files in `mathebuddy-public-courses`.

4. **`kill process at port 8314`**

- normally not needed
- in case that the HTTP-server hangs up, this choice stops it

5. **`exit`**

- quits the Python script

# Visual Studio Code (VS-Code)

Files in repository `mathebuddy-public-courses` can be edited with a plaintext editor of choice.

> Do **NOT** use M$ Word or LibreOffice to edit files, since word processors are not outputting plaintext files!

We suggest do use Visual Studio Code to edit files, since we will provide a plugin for it in the future anyway. Visit [https://code.visualstudio.com](https://code.visualstudio.com) for install instructions.

> Tip: On Linux you can install VS-Code via `sudo apt install code`. On macOS you can install it via `brew install visual-studio-code`.

Open Visual Studio Code and open repository `mathebuddy-public-courses` on your disk.

> WARNING: First start making changes in the playground!!

# Committing Changes

> WARNING: committing code to the public-course directory is yet only permitted to the mathe:buddy core team.

Committing changes can be done on the command line via git:

```
cd YOUR_DIR/mathebuddy-public-courses
git add --all
git commit -m "YOUR COMMIT MESSAGE HERE"
git push
```

## GitHub Desktop

GitHub Desktop provides a nice graphical user interface to interact with GitHub projects (... and also other `git`-repositories). Follow the install instructions from [https://desktop.github.com](https://desktop.github.com) and open GitHub Desktop.

Choose `[File]` $\to$ `[add local repository]` in the main menu and choose `YOUR_DIR/mathebuddy-public-courses` on your local disk.

GitHub Desktop will show every current and past change in the repository.

# A day in the life of a content creator

The base installation must only be done once.

Daily procedure:

1. Start `server.py`: first do the updates and then run the web-server. Open `https://localhost:8314` in your favorite browser.
2. Open the directory `mathebuddy-public-courses` in Visual Studio Code.
3. Open GitHub Desktop.
4. Fetch the latest course updates for `mathebuddy-public-courses` in GitHub Desktop.
5. Write courses to explain math to the world.
6. Debug your courses in the simulator @ `https://localhost:8314`.
7. Share your work with GitHub Desktop.
8. If you are tired, then STOP.
9. Go to step 4.

_Author: Andreas Schwenk, TH Köln_
