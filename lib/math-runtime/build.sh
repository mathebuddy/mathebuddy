#!/bin/bash
#!/bin/bash
echo "# extracted automatically by running ./build.sh" > grammar.txt
cat src/parse.dart | grep //G | cut -c7- >> grammar.txt
