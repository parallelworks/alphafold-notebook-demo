# Script to apply a tag to a notebook cell based
# on cell contents.  Modified from example at:
# https://jupyterbook.org/en/stable/content/metadata.html
#=============================================

import nbformat as nbf
import sys

# Set the name of the notebook to work on
print("tag_cells: Setting ntbk_path = "+sys.argv[1])
ntbk_path = sys.argv[1]

# Text to look for in adding tags
text_search_dict = {
    "#@title Install dependencies": "remove-cell",
    "#@title Display 3D structure": "remove-cell",
    "#@title Plots": "remove-cell",
    "#@title Package and download results": "remove-cell"
    }

# Load notebook
ntbk = nbf.read(ntbk_path, nbf.NO_CONVERT)

for cell in ntbk.cells:
    cell_tags = cell.get('metadata', {}).get('tags', [])
    for key, val in text_search_dict.items():
        if key in cell['source']:
            if val not in cell_tags:
                cell_tags.append(val)
                if len(cell_tags) > 0:
                    cell['metadata']['tags'] = cell_tags
nbf.write(ntbk, ntbk_path)
