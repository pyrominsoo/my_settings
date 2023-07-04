import sys
import subprocess

if len(sys.argv) != 4:
    print("Number of arguments != 4")
    raise

urlBase = sys.argv[1]
separator = '/'
result = urlBase.rsplit(separator, 1)[0]
urlBase = result + '/'
beginIdx = int(sys.argv[2])
endIdx = int(sys.argv[3])

for i in range(beginIdx, endIdx+1):
    url = urlBase + str(i) + ".jpg"
    result = subprocess.run(["wget", url])
