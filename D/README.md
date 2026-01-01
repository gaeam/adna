# D

https://zhuanlan.zhihu.com/p/615080742

D-statistics 不同软件的计算公式可能不一样

**（1）AdmixTools**
The 4-population test, implemented here as D-statistics, is also a formal test for admixture based on a four taxon 4 statistic, which can provide some information about the direction of gene ﬂow.
For any 4 populations (W, X, Y, Z), qpDstat computes the D-statistics as - 
num = (w − x)(y − z )
den = (w + x − 2wx)(y + z − 2yz )
D = num/ den
The output of qpDstat is informative about the direction of gene flow. So for 4 populations (W, X, Y, Z) as follows - 
If the Z-score is +ve, then the gene flow occured either between W and Y or X and Z 
If the Z-score is -ve, then the gene flow occured either between W and Z or X and Y. 
**（2）ANGSD**
ABBA-BABA