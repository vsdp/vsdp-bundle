# The file BIB_FILE must use the following biber format:
#
#     cp BIB_FILE.bib BIB_FILE.bib~
#     biber --tool --output-fieldcase=lower --output-indent=2 \
#           --output-align --output-file BIB_FILE.bib BIB_FILE.bib~
#

import argparse
import re
import sys
from os import path
from string import Template

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--format", nargs=1, choices=["html5", "markdown"],
                    help="Output format", default=["html5"])
parser.add_argument("-o", "--output", nargs=1, help="Output file")
parser.add_argument("BIB_FILE", help="Input BibLaTeX file")
args = parser.parse_args()

if args.output is not None:
    out_file = args.output[0]
else:
    out_file = path.basename(args.BIB_FILE)
    out_file, _ = path.splitext(out_file)
    if (args.format[0] == "html5"):
        out_file += ".html"
    else:
        out_file += ".md"

md_header_template_str = Template("""---
title: References
permalink: references.html
---

## References

Download all references in BibTeX format:
[references.bib](/doc/bibliography/references.bib).
""")
md_footer_template_str = Template("")

md_item_template_str = Template("""
- <a id="$KEY"></a>
  *$AUTHORS*
  **"$TITLE"**
  ($DATE).

  $DOI_OR_URL
  <details>
  <summary>Show BibTeX</summary>
  <pre>
$BIBTEX
  </pre>
  </details>

  &nbsp;

""")

html_header_template_str = Template("""<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>References</title>
</head>
<body>
<ul>
""")

html_footer_template_str = Template("""
</ul>
</body>
""")

html_item_template_str = Template("""
<li><a id="$KEY">[$KEY]</a>
  <i>$AUTHORS</i>
  <b>"$TITLE"</b>
  ($DATE).

  $DOI_OR_URL
  <details>
  <summary>Show BibTeX</summary>
  <pre>
$BIBTEX
  </pre>
  </details>
</li>
""")

if (args.format[0] == "html5"):
    header_template_str = html_header_template_str
    footer_template_str = html_footer_template_str
    item_template_str = html_item_template_str
    doi_template_str = Template("<a href=\"https://doi.org/$DOI\">[DOI]</a>")
    url_template_str = Template("<a href=\"$URL\">[URL]</a>")
else:
    header_template_str = md_header_template_str
    footer_template_str = md_footer_template_str
    item_template_str = md_item_template_str
    doi_template_str = Template("DOI: <https://doi.org/$DOI>")
    url_template_str = Template("URL: <$URL>")

# Read all references to a list
with open(args.BIB_FILE, "rb") as bib_file:
     bib_list = bib_file.read().decode("utf-8").split("\n\n")
     bib_list[-1] = bib_list[-1][0:-1] # Trim last newline

# Convert the list to a dictionary
bib_dict = dict()
for idx, bib_item in enumerate(bib_list):
    key = re.match(r"@.*\{(.*),", bib_item).group(1)
    authors = ""
    title = ""
    date = ""
    doi = ""
    url = ""
    for line in bib_item.split("\n"):
        title_match = re.match(r"  title *= \{(.*)\},", line)
        authors_match = re.match(r"  author *= \{(.*)\},", line)
        date_match = re.match(r"  date *= \{(.*)\},", line)
        doi_match = re.match(r"  doi *= \{(.*)\},", line)
        url_match = re.match(r"  url *= \{(.*)\},", line)
        if title_match:
            title = title_match.group(1)
        if authors_match:
            authors = authors_match.group(1)
        if date_match:
            date = date_match.group(1)
        if doi_match:
            doi = doi_match.group(1)
        if url_match:
            url = url_match.group(1)
    if doi != "":
        doi_or_url = doi_template_str.substitute(DOI=doi)
    elif url != "":
        doi_or_url = url_template_str.substitute(URL=url)
    else:
        doi_or_url = ""
    bib_dict[key] = (authors, title, date, doi_or_url, bib_list[idx])

with open(out_file, "w") as ofile:
    ofile.write(header_template_str.substitute())
    for key, bib_item in bib_dict.items():
        ofile.write(item_template_str.substitute(KEY=key,
                                                 AUTHORS=bib_item[0],
                                                 TITLE=bib_item[1],
                                                 DATE=bib_item[2],
                                                 DOI_OR_URL=bib_item[3],
                                                 BIBTEX=bib_item[4]))
    ofile.write(footer_template_str.substitute())
