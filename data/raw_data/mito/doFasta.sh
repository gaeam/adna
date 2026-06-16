#!/bin/bash

/home/kexin_li/angsd/angsd \
  -i \
  -doFasta 2 \
  -doCounts 1 \
  -dumpCounts 3 \
  -doDepth 1 \
  -out

# doFasta 1: use a random (non N) base (needs -doCounts 1)
# doFasta 2: use the most common (non N) base (needs -doCounts 1)
#
