from __future__ import print_function
import json
import sys
import urllib2


def usage():
	print("USAGE:")
	print("\tstdin should be a csv of namespace numbers and pagenames")
	print("\tthe url to the api.php endpoint of the repository should be the only argument")

if len(sys.argv) != 2:
	usage()
	exit()

conn = urllib2.urlopen(sys.argv[1] + "?action=query&meta=siteinfo&siprop=namespaces&format=json")
namespace_map = json.loads(conn.read())["query"]["namespaces"]

for line in sys.stdin.readlines():
	if line.strip() == "":
		continue
	split = line.split("\t")
	split = [x.strip() for x in split]
	if len(split) == 1:
		print(split[0])
		continue
	namespace_id, pagename = split
	namespace = namespace_map[namespace_id]["*"]
	if namespace != "":
		namespace += ":"
	print(namespace + pagename)
