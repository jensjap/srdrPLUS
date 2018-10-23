from Bio import Entrez
import xml.etree.ElementTree as ET
import re
import csv
import sys

f = open(sys.argv[1])

pmid_file = open(sys.argv[2], 'w+')
csvwriter = csv.writer(pmid_file, delimiter=',', quotechar='"')

Entrez.email = "birol_senturk@brown.edu"

for l in f:
	term = re.sub('[^A-Za-z0-9 -.]+', '', l).strip()
	record = Entrez.esearch(db='pubmed', term=term)
	r = Entrez.read(record)
        #import pdb; pdb.set_trace()
	csvwriter.writerow([term] + r['IdList'])

f.close()
pmid_file.close()
