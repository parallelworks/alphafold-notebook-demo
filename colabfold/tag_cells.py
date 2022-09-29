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
text_rm_cell_dict = {
    "#@title Install dependencies": "remove-cell",
    "#@title Display 3D structure": "remove-cell",
    "#@title Plots": "remove-cell",
    "#@title Package and download results": "remove-cell"
    }

# Test to grab cell contents separately
text_shell_cell_dict = {
    "%%bash": "extract-cell"
    }
n_shell=0

# Load notebook
ntbk = nbf.read(ntbk_path, nbf.NO_CONVERT)

# Scan each cell for text above and add corresponding
# tag if present.
for cell in ntbk.cells:
    cell_tags = cell.get('metadata', {}).get('tags', [])
    for key, val in text_rm_cell_dict.items():
        if key in cell['source']:
            if val not in cell_tags:
                cell_tags.append(val)
                if len(cell_tags) > 0:
                    cell['metadata']['tags'] = cell_tags

    # Also search for any magic bash scripts and extract
    # separately.
    for key, val in text_shell_cell_dict.items():
        if key in cell['source']:
            n_shell = n_shell + 1
            f = open("ntbk_shell_"+str(n_shell)+".sh", "w")
            f.write(cell['source'])
            f.close()
            
nbf.write(ntbk, ntbk_path)
