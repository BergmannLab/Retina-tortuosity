from PIL import Image
import os
import sys

# Rename images name deleting '_bin_seg'
def remove_bin_seg(images_input_dir, all_files):
    for filename in all_files:
        im1 = Image.open(os.path.join(images_input_dir, filename))
        prefix = filename.split('_bin_seg.')[0]
        png_filename = f'{prefix}.png'
        im1.save(os.path.join(images_input_dir, png_filename))

images_input_dir = sys.argv[1] 
filetype = '_bin_seg.png' 

all_files = [f for f in os.listdir(images_input_dir) if f.endswith(filetype[1:])]
print(all_files)

remove_bin_seg(images_input_dir, all_files)

#TO DO remove the images repeated with _bin_seg!!!!