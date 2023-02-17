# mathe:buddy - a gamified learning-app for higher math
# (c) 2022-2023 by TH Koeln
# Author: Andreas Schwenk contact@compiler-construction.com
# Funded by: FREIRAUM 2022, Stiftung Innovation in der Hochschullehre
# License: GPL-3.0-or-later

# This file provides a simple http-server listening to port 8271
# or a port given as arg

# python3 server.py          listens to port 8271
# python3 server.py 8314     listens to port 8314

# Place this file to your mathe:buddy working directory that contains
# one or more courses.

# Head to https://mathebuddy.github.io/mathebuddy/ and run the simulator.
# Your local courses will be visible there.

# DEV-INFO: The current version of this file

from http.server import HTTPServer, SimpleHTTPRequestHandler, test
import sys


class CORSRequestHandler (SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        SimpleHTTPRequestHandler.end_headers(self)


if __name__ == '__main__':
    port = 8271
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    test(CORSRequestHandler, HTTPServer, port=port)
