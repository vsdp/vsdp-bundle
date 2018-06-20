# The file references.bib using the following biber format is required:
#
#     cp references.bib references.bib~
#     biber --tool --output-fieldcase=lower --output-indent=2 \
#           --output-align --output-file references.bib references.bib~
#

import re
from string import Template

md_header = """---
title: References
permalink: references.html
---

## References
"""

item_template_str = Template("""
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

# Read all references to a list
with open("references.bib", "rb") as bib_file:
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
        doi_or_url = "DOI: <https://doi.org/" + doi + ">"
    elif url != "":
        doi_or_url = "URL: <" + url + ">"
    else:
        doi_or_url = ""
    bib_dict[key] = (authors, title, date, doi_or_url, bib_list[idx])

with open("references.md", "w") as md_file:
    md_file.write(md_header)
    for key, bib_item in bib_dict.items():
        md_file.write(item_template_str.substitute(KEY=key,
                                                   AUTHORS=bib_item[0],
                                                   TITLE=bib_item[1],
                                                   DATE=bib_item[2],
                                                   DOI_OR_URL=bib_item[3],
                                                   BIBTEX=bib_item[4]))
