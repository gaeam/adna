import sys
import os

sys.path.append('/Users/likexin/Desktop/script/nuclear/D-statistics/fstat_funcs.py')
import fstat_funcs as ff

homedir="/Users/likexin/Desktop/cattle/D-statistics/251215/" ####CHANGE
pD=homedir  ##Directory your data (IND/SNP/GENO) are in.
outpd=homedir  ##Directory you want to put PAR file in.
fh="modern201_ap114_aoc5_aoy6_waterbufllo2.pileupCaller" ####CHANGE

#myfile=open(outpd+"testdataP1.list")
#p1=[line.strip() for line in myfile]
#myfile.close()

myfile=open(pD+"P1P2.list")
mypops=[line.strip() for line in myfile]
myfile.close()

myfile=open(pD+"target.list")
p2p3=[line.strip() for line in myfile]
myfile.close()

##Making PAR and POP files for D-statistic
out=["outgroup"]   #### CHANGE

label="P3" #### CHANGE
ff.Df4pop(pD,fh,"D",label,mypops,mypops,p2p3,out,outpd=outpd)
ff.parfile(pD,fh,"D",label,outpd=outpd)
label="P2" #### CHANGE
ff.Df4pop(pD,fh,"D",label,mypops,p2p3,mypops,out,outpd=outpd)
ff.parfile(pD,fh,"D",label,outpd=outpd)
