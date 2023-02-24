# mathe:buddy

Official website with simulator and playgrounds: [https://mathebuddy.github.io/mathebuddy/](https://mathebuddy.github.io/mathebuddy/)

## Users and Content Creators Info

- If you only like to use playgrounds or test the simulator with example files, there is no need to install anything. Just visit [https://mathebuddy.github.io/mathebuddy/](https://mathebuddy.github.io/mathebuddy/)

- If you like to create and test your own courses, visit the website, head to `simulator` and click on button `http://localhost:8271`. Then follow the instructions listed.

## Developers Info

This repository implements all components of the `mathe:buddy` app.

<!-- for the iOS App Store and Google Playground.-->

![](img/mathebuddy-comp-diag.png)

## File Structure

| Path                      | Description                                       |
| ------------------------- | ------------------------------------------------- |
| .vscode/                  | Visual Code Project Settings                      |
| app/                      | Implementation of the App with Flutter            |
| bin/                      | Scripts                                           |
| doc/                      | Documentation of SMPL, MBL, MBCL                  |
| docs/                     | Website: https://mathebuddy.github.io/mathebuddy/ |
| ext/                      | External Components                               |
| img/                      | Original image files                              |
| lib/                      | Implementation of components (math-runtime, ...)  |
| cmd.sh                    | Administration script for developers              |
| web.sh                    | Starts the webserver locally                      |
| mathebuddy.code-workspace | Workspace for VSCode                              |

Head to the `README.md` files in the subdirectories for more information.

## Installation

_Other operating systems than Debian and macOS are not yet supported. Only macOS allows to build an iOS version of the app._

### Dependencies

**IMPORTANT: If you only like to run the webserver locally (including all playgrounds and the simulator), you only need to install Python 3. The repository delivers up-to-date built libraries in the `docs/` directory.**

<!-- TODO: android SDK, XCode, ... -->

Note: Android and XCode can be skipped, if you only like to compile and run `mathe:buddy` simulator. `pandoc` can be skipped if you do not intend to build the manuals.

- Debian based Linux (e.g. Ubuntu)

  ```
  sudo apt install python3 snapd pandoc
  sudo snap install flutter --classic
  ```

- macOS

  First install the [brew package manager](https://brew.sh).

  ```
  brew install git python3 flutter pandoc
  ```

Then run `flutter doctor` in a terminal window and install all listed dependencies.

- macOS

  Install `Xcode` from the App Store and start the application to complete the installation.
  Then run the following commands from a terminal.

  ```
  xcode-select --install
  sudo gem install cocoapods
  brew install --cask android-studio
  brew install bundletool
  ```

  Run the application `Android Studio.app`, agree to the licenses and complete the setup.
  In Android Studio Settings, Choose `Appearance & Behavior`, `System Settings`, `Android SDK` and select in tab `[SDK Platforms]` (e.g.) `Android 13`. Then select in tab `[SDK Tools]` `Android SDK Command-line Tools (latest)`. Click on the `Accept` button to start the installation.

  In a terminal, run `flutter doctor --android-licenses` and accept each license with `y`. Then run `flutter doctor` again to check installation.

  In case that you do not have no Java runtime, run `brew install openjdk` to install it. Homebrew will output that you have to run `echo 'export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"' >> ~/.zshrc`. Do it!

  A recent bug ([https://github.com/flutter/flutter/issues/118502](https://github.com/flutter/flutter/issues/118502)) may list Java Errors. Run the following (ugly!) fix:

  ```
  cd /Applications/Android\ Studio.app/Contents
  cp -r jbr jre
  ```

  <!-- In case of Java Errors, run `export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jbr/Contents/Home` and then run `flutter doctor` again.-->

### Getting mathe:buddy

You now need to clone the following _mathe:buddy_ repositories. Replace `YOUR_FAVORITE_DIRECTORY` by a local directory on your disk.

> TIP: use [GitHub Desktop](https://desktop.github.com) to clone the repositories (refer to the end of this document).

```
cd YOUR_FAVORITE_DIRECTORY
git clone https://github.com/mathebuddy/mathebuddy.git
git clone https://github.com/mathebuddy/mathebuddy-public-courses.git
```

Developers of the core team should use a SSH key pair; see
[https://docs.github.com/en/authentication/connecting-to-github-with-ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh); and also clone the private repository:

```
cd YOUR_FAVORITE_DIRECTORY
git clone git@github.com:mathebuddy/mathebuddy.git
git clone git@github.com:mathebuddy/mathebuddy-public-courses.git
git clone git@github.com:mathebuddy/mathebuddy-private-courses.git
```

> WARNING: Never(!!) clone to iCloud / GoogleDrive / OneDrive / NextCloud / Sciebo / ...!

### Running the website locally

Run the following commands:

```
cd YOUR_FAVORITE_DIRECTORY/mathebuddy/docs
python3 -m http.server 8314
```

Open `http://localhost:8314/` in your favorite browser. You may choose some other port than `8314`.

Alternatively, you may also use script `./web.sh` (or the admin tool `./cmd.sh`) in the root directory of the repository.

```
cd YOUR_FAVORITE_DIRECTORY/mathebuddy
./web.sh
```

### Build

We use [VSCode](https://code.visualstudio.com) for editing source code.
Make sure you install ALL recommended extensions: Open the `mathebuddy` repository in VSCode, then click on `Extensions` on the left symbol div. Type `@recommended` in the search field. Then click on `Install` on each extension that is not yet installed.

(TODO: this section will be extended soon...)

## Repository List

<!--List of all repositories
Also consider the other repositories of this GitHub account. You will find a list below.-->

- https://github.com/mathebuddy/mathebuddy

  iOS and Android App (implemented with Flutter)

- https://github.com/mathebuddy/mathebuddy-public-courses

  Free and Open Source Math Courses

<!--
- https://github.com/mathebuddy/mathebuddy-downloads

  Downloadable toolchains and data for the mathe:buddy app (e.g. VSCode Plugins)

- https://github.com/mathebuddy/mathebuddy-compiler

  Course Description Language Compiler (converts human-readable course definitions into a machine-oriented language)

- https://github.com/mathebuddy/mathebuddy-smpl

  Simple Math Programming Language (SMPL) for the Web (used to create random math questions)

- https://github.com/mathebuddy/mathebuddy-simulator

  Course Simulator with Debugging Features (used in the web IDE and the VSCode plugins)

- https://github.com/mathebuddy/mathebuddy-math-runtime

  Simple Math Runtime for the App (partly based on SMPL)

- https://github.com/mathebuddy/mathebuddy-ide

  Web Editor to compose Courses for the App

- https://github.com/mathebuddy/mathebuddy-vscode-lang-ext

  Language Extension for Visual Studio Code (syntax and semantical highlighting)

- https://github.com/mathebuddy/mathebuddy-vscode-sim-ext

  Simulator Extension for Visual Studio Code (simulation)

- https://github.com/mathebuddy/mathebuddy-website

  Website for the MatheBuddy App (https://app.f07-its.fh-koeln.de)
-->
