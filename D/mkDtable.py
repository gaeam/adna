import sys
import os

sys.path.append('/Users/likexin/Desktop/script/nuclear/D-statistics/fstat_funcs.py')
import fstat_funcs as ff

homedir="/Users/likexin/Desktop/cattle/D-statistics/251215/"  #### CHANGE
pD=homedir
outpd=homedir   
fh="modern201_ap114_aoc5_aoy6_waterbufllo2.pileupCaller"

## Note that I could have also called the files "EastAsia.txt" and "CentralAsiaSiberia.txt" 
## like above. This just depends on personal preference. 
myfile=open(outpd+"P1P2.list")
mypops=[line.strip() for line in myfile]
myfile.close()

myfile2=open(outpd+"target.list")
mainpops=[line.strip() for line in myfile2]
myfile2.close()          #### CHANGE

for mainpop in mainpops:
    label="P3"
    myary=ff.Dmkary(outpd,fh+".D."+label+".log",[mypops,mypops,mainpop,"outgroup"],"Z")
    ff.Dmat2xlsx(myary,outpd+fh+".P3_%s" % mainpop,"D(X,Y;%s,outgroup)" % mainpop,mypops,mypops) # %s 是把变量插进字符串里，即把 mainpop 插进字符串里

    label="P2"
    myary=ff.Dmkary(outpd,fh+".D."+label+".log",[mypops,mainpop,mypops,"outgroup"],"Z")
    ff.Dmat2xlsx(myary,outpd+fh+".P2_%s" % mainpop,"D(X,%s;Y,outgroup)" % mainpop,mypops,mypops)
