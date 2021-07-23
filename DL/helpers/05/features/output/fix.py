import os
import numpy as np

files = [l for l in os.listdir("./") if "last" in l][0]
print(files)

new_filename = files.replace(".csv","_FIXED.csv")
f_object_old = open(files,"r")
f_object = open(new_filename,"w+")

f_object.write(f_object_old.readline())

for line in f_object_old:
	if "node" in line:
		continue
	else:
		f_object.write(line)

f_object_old.close()
f_object.close()
