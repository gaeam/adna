

def Df4pop(pd,fh,partype,label,P1,P2,P3,P4,excluded=[],outpd=None,popfile=True):
    """
    
    Write POP file for D- and f4-statistics. This script allows 
    customization of list, choosing who to rotate through in each position, 
    with the option to run all 
    
    pd       -- data directory
    fh       -- filehandle for the IND/SNP/GENO files - only IND file will be used (if data.ind, then "data")
    partype  -- D or f4, to indicate on label.
    label    -- New label to give to resulting file
    P1       -- List populations to fix P1 to. Setting to [] means all IND file.
    P2       -- List populations to fix P2 to. Setting to [] means all IND file.
    P3       -- List populations to fix P3 to. Setting to [] means all IND file.
    P4       -- List populations to fix P4 to. Setting to [] means all IND file.
    excluded -- specifically who to exclude, only works with all IND file option, default is [], excluding no population
    outpd    -- directory to place results in, if using default None, then will be placed in data directory
    popfile  -- Default True, use popfilename. If False, then only takes P1 list for poplistname. 
    
    """
    if P1==[] or P2==[] or P3==[] or P4==[]:
        indfile=open(pd+fh+".ind",'r')
        mypops=[]
        for line in indfile:
            x=line.split()
            if x[2] not in mypops: 
                if len(included)!=0: 
                    if x[2] in included: 
                        mypops.append(x[2])
                else: mypops.append(x[2])
        indfile.close()
        if len(excluded)!=0: 
            for popn in excluded: mypops.remove(popn)
        if P1==[]: P1=mypops
        if P2==[]: P2=mypops
        if P3==[]: P3=mypops
        if P4==[]: P4=mypops
    
    if outpd==None: mypd=pd
    else: mypd=outpd
    newpopfile=open(mypd+fh+'.'+ partype + '.'+label+".pop",'w')
    if popfile==True:    
        mytuples=[ (A, B, C, D) for A in P1 for B in P2 for C in P3 for D in P4 if len(set((A,B,C,D)))==4]
        for mytup in mytuples: newpopfile.write("\t".join(mytup)+"\n")    
    else:
        for pop in P1: newpopfile.write(pop+"\n")         
    newpopfile.close()     
    
    return "Made %s%s.%s.%s.pop POP file" % (mypd,fh,partype,label)

def Dmklabel(pops,X="X",Y="Y"):
    """
    
    Make a label D(P1, P2; P3, P4) using four population list used in mkDary().
    
    pops -- List with two strings and two lists used in mkDary()
    X    -- To indicate first list in string, default "X"
    Y    -- To indicate second list in string, default "Y"
    
    """
    Dname=[]
    for i in pops:
        if type(i)==str: Dname.append(i)
        else: 
            if X not in Dname: Dname.append(X)
            else: Dname.append(Y)
    return "D(%s, %s; %s, %s)" % tuple(Dname)

def Dmkary(pD,fh,pops,DorZ,sd=False):
    """
    
    Make a numpy array of either D values or Z-scores. Takes a log file from qpDstat as input.
    
    ## pD     =log file directory
    ## fh     =filename (including suffix)
    ## pops   =list of four populations in order of [P1, P2, P3, P4] - two are lists; two are strings
    ## DorZ   ="D" or "Z" indicating what to retrieve for array
    ## sd     =whether PAR file specified adding Std Error in. If not, then "False", if yes, then "True"
    
    """
    
    import numpy as np
    
    if DorZ=="Z":   
        if sd==False: DorZind=5 
        else: DorZind=6
    elif DorZ=="D": DorZind=4
    else: return "Not Z or D!"
    
    stable = [ind for ind,i in enumerate(pops) if type(i)==str]
    vary = [ind for ind,i in enumerate(pops) if type(i)==list]
    stabpop1,stabpop2=(pops[stable[0]],pops[stable[1]])
    varypop1,varypop2=(pops[vary[0]],pops[vary[1]])
    
    myary=np.zeros((len(varypop1),len(varypop2)))
    myary[myary==0]=np.nan
    myDs={}
    dfile=open(pD+fh,'r')
    for line in dfile:
        if 'result' not in line: continue
        x=line.split()[1:]
        a,b,c,d=x[:4]
        if stabpop1 not in [a,b,c,d] or stabpop2 not in [a,b,c,d]: continue
        D={}
        D[(a,b,c,d)]=float(x[DorZind])
        D[(b,a,c,d)]=-float(x[DorZind])
        D[(a,b,d,c)]=-float(x[DorZind])
        D[(b,a,d,c)]=float(x[DorZind])
        for dset in D:
            if dset[vary[0]] in varypop1 and dset[vary[1]] in varypop2 and dset[stable[0]]==stabpop1 and dset[stable[1]]==stabpop2:
                p1ind,p2ind=(varypop1.index(dset[vary[0]]),varypop2.index(dset[vary[1]]))
                myary[p1ind,p2ind]=D[dset]
    dfile.close()
    return myary

def Dmat2xlsx(myary,newfh,label,rownames,colnames,descriptor="X/Y"):
    """
    
    Turn numpy array into formatted table. 
    
    myary      -- numpy array, probably from the function mkDary()
    newfh      -- new filehandle for Excel - without ".xlsx", needs directory
    label      -- header to put above the table in Excel, usually some form of D(P1, P2; P3, P4)
    rownames   -- list of rownames matching array rows
    colnames   -- list of colnames matching array columns
    descriptor -- default: X/Y, but whatever to indicate rows and columns
    
    """
    
    import xlsxwriter as xls
    newfile=xls.Workbook(newfh+".xlsx")
    worksheet=newfile.add_worksheet()
    
    mynum = newfile.add_format({'num_format': '0.0','center_across':True})
    bold = newfile.add_format({'bold': True,'align':'center','valign':'vcenter'})
    colheader=newfile.add_format({'bold': True,'align':'center','valign':'vcenter','rotation':90})
    nan = newfile.add_format({'align':'center','valign':'vcenter'})
    
    ##SWITCHED FROM TY FORMATS BC DFREQ DOES OPPOSITE ABBA-BABA (not BABA-ABBA!)
    g2_5 = newfile.add_format({'center_across':True,'bold':True,
                               'font_color':'#9C0006','bg_color':'white',
                               'num_format': '0.0'})
    g3 = newfile.add_format({'center_across':True,'bold':True,'font_color':'#9C0006',
                               'bg_color':'#FFC7CE','num_format': '0.0'})
    l2_5 = newfile.add_format({'center_across':True,'bold':True,'font_color':'#000080',
                               'bg_color':'white','num_format': '0.0'})
    l3 = newfile.add_format({'center_across':True,'bold':True,'font_color':'#000080',
                               'bg_color':'#83CFF6','num_format': '0.0'})
    
    worksheet.set_column(1,len(colnames)+1,4)
    worksheet.set_column(0,0,8)
    alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    worksheet.merge_range(0,1,0,len(colnames),label,bold)
    row,col=1,0
    worksheet.write_string(row,col,descriptor,bold)
    for ind,i in enumerate(colnames): worksheet.write_string(row,col+ind+1,i,colheader)
    for myind in range(myary.shape[0]):
        #print rownames[myind]
        worksheet.write_string(row+myind+1,col,rownames[myind],bold)
        for myind2,i2 in enumerate(myary[myind,:]):
            if str(i2)=="nan": 
                worksheet.write_string(row+myind+1,col+myind2+1,"nan",nan)
            else:
                if i2>=2.5 and i2<2.95: 
                    worksheet.write_number(row+myind+1,col+myind2+1,i2,mynum) #,g2_5)
                elif i2>=2.95:
                    worksheet.write_number(row+myind+1,col+myind2+1,i2,g3)
                elif i2<=-2.5 and i2>-2.95:
                    worksheet.write_number(row+myind+1,col+myind2+1,i2,mynum) #,l2_5)
                elif i2<=-2.95:
                    worksheet.write_number(row+myind+1,col+myind2+1,i2,l3)
                else:
                    worksheet.write_number(row+myind+1,col+myind2+1,i2,mynum)    
    newfile.close()
    return "Made %s!" % newfh


def f3pop(pd,fh,label,Target=None,S1=None,S2=None,included=[],excluded=[],outpd=None,r_repeat=True):
    """
    
    Write POP file for f3-statistics. This script allows some customization of list, particularly allowing
    specification of who to include in one or more of the three columns. 
    
    pd       -- data directory
    fh       -- filehandle for the IND/SNP/GENO files - only IND file will be used (if data.ind, then "data")
    label    -- New label to give to resulting file
    Target   -- List populations to fix Target to. Default None means will use all unless included/excluded used.
    S1       -- List populations to fix S1 to. Default None means will use all unless included/excluded used.
    S2       -- List populations to fix S2 to.  Default None means will use all unless included/excluded used.
    included -- specifically who to include, provide a list. If all IND file, then use default [] (empty list)
    excluded -- specifically who to exclude, trumps included list, default is [], excluding no population
    outpd    -- directory to place results in, if using default None, then will be placed in data directory
    r_repeat -- Remove combinations where f3(X, Y; Target) and f3(Y, X; Target) as same result. Default is to remove (True)
    
    """
    
    indfile=open(pd+fh+".ind",'r')
    mypops=[]
    for line in indfile:
        x=line.split()
        if x[2] not in mypops: 
            if len(included)!=0: 
                if x[2] in included: 
                    mypops.append(x[2])
            else: mypops.append(x[2])

    if len(excluded)!=0: 
        for popn in excluded: mypops.remove(popn)
    if S1==None: S1=mypops
    if S2==None: S2=mypops
    if Target==None: Target=mypops
        
    if r_repeat==True:
        mytuples=[ (A, B, C) for A in S1 for B in S2 for C in Target if len(set([A,B,C]))==3 ]
    else:
        mytuples=[ (A, B, C) for A in S1 for B in S2 for C in Target ]
    if outpd==None: mypd=pd
    else: mypd=outpd
    newpopfile=open(mypd+fh+'.f3.'+label+".pop",'w')
    for mytup in mytuples:
        newpopfile.write("\t".join(mytup)+"\n")
    newpopfile.close() 
    
    return "Made %s%s.f3.%s.pop POP file" % (mypd,fh,label)

def f3mkary(pD,fh,pops,forZ="f"):
    """
    
    Make a numpy array of either D values or Z-scores. Takes a log file from qpDstat as input.
    
    ## pD     =log file directory
    ## fh     =filename (including suffix)
    ## pops   =list of three populations in order of [S1, S2, Target] - two are lists; one is string
    ## forZ   ="f" or "Z" or "se" indicating what to retrieve for array
    
    """
    
    import numpy as np
    
    if forZ=="Z":    forZind=5 
    elif forZ=="f": forZind=3
    elif forZ=="se": forZind=4
    else: return "Not Z or f or se!"
    
    stable = [ind for ind,i in enumerate(pops) if type(i)==str]
    vary = [ind for ind,i in enumerate(pops) if type(i)==list]
    stabpop=pops[stable[0]]
    varypop1,varypop2=(pops[vary[0]],pops[vary[1]])
    
    myary=np.zeros((len(varypop1),len(varypop2)))
    myary[myary==0]=np.nan
    myDs={}
    dfile=open(pD+fh,'r')
    for line in dfile:
        if 'result' not in line: continue
        x=line.split()[1:]
        a,b,c=x[:3]
        if stabpop not in [a,b,c]: continue
        f3={}
        f3[(a,b,c)]=float(x[forZind])
        f3[(b,a,c)]=float(x[forZind])
        for dset in f3:
            if dset[vary[0]] in varypop1 and dset[vary[1]] in varypop2 and dset[stable[0]]==stabpop :
                p1ind,p2ind=(varypop1.index(dset[vary[0]]),varypop2.index(dset[vary[1]]))
                myary[p1ind,p2ind]=f3[dset]
    dfile.close()
    return myary

def parfile(pD,fh,partype,label,outpd="",indfh="",popfh="",badsnp="",
            inbreed=False,convertf="ANCESTRYMAP",popfile=True,sd=False,
            outgroup=""):
    """
    
    Write PAR file for qp3Pop (f3), qpDstat (D or f4), convertf (CONVERTF)
                       qpWave (wave), qpAdm (adm)
    
    pD       --  dir path for data files
    fh       --  filehandle for data files
    partype  --  either 'D','f3','f4','CONVERTF','wave','adm'
    label    --  special label for that PAR file
    outpd    --  dir path to put PAR file in (if "" then defaults to data dir)
    indfh    --  new indfilename (if "" then defaults to fh)
    popfh    --  new popfilename (if "" then defaults to [fh].[partype].[label].pop)
    badsnp   --  badsnpfilename, needs suffix, (if "" then not included)
    inbreed  --  for f3, if False then not included, put to True for pseudo-diploid target
    convertf --  fileformat to convert to (ANCESTRYMAP, PACKEDANCESTRYMAP, PED, PACKEDPED, EIGENSTRAT)
    popfile  --  for D/f4, if True, then use popfilename (default); if False, then use poplistname
    sd       --  Whether LOG file should include column for standard error (default is no, False, put True to include). 
    outgroup --  For qpWave/qpAdm, specifies rightpop file to use. Default "", where same name as label and leftpop. 
    outgroup --  If for f3, and set to True, then adds outgroupmode to PAR file. 
    
    """
    
    mypD=pD if outpd == "" else outpd
    myfile = open(mypD+fh+'.%s.' % partype +label+'.par', 'w')
    myfile.write('genotypename:\t'+pD+fh+'.geno\n')
    myfile.write('snpname:\t'+pD+fh+'.snp\n')
    if indfh!="": myfile.write('indivname:\t'+pD+indfh+'.ind\n')
    else: myfile.write('indivname:\t'+pD+fh+'.ind\n')
    
    if partype=="CONVERTF":
        myfile.write('outputformat:\t'+convertf+'\n')
        myfile.write('genotypeoutname:\t'+pD+fh+'.'+label+'.geno\n')
        myfile.write('snpoutname:\t'+pD+fh+'.'+label+'.snp\n')
        if indfh!="": myfile.write('indivoutname:\t'+pD+indfh+'.'+label+'.ind\n')
        else: myfile.write('indivoutname:\t'+pD+fh+'.'+label+'.ind\n')
    if partype in ["D","f3","f4"]:
        if popfh!="": myfile.write('popfilename:\t'+mypD+popfh+'.pop\n')
        else: myfile.write('popfilename:\t'+mypD+fh+'.%s.' % partype+label+'.pop\n')
        if partype=="f3":
            if inbreed == True: myfile.write('inbreed:\tYES\n')
            if outgroup== True: myfile.write('outgroupmode:\tYES\n')
        if partype=="f4":
            myfile.write("f4mode:\tYES\n")
            if sd==True: myfile.write("printsd:\tYES\n")
        if partype=="D":
            myfile.write("f4mode:\tNO\n")
            if sd==True: myfile.write("printsd:\tYES\n")
    if badsnp != "": myfile.write('badsnpname:\t'+pD+badsnp)
    
    if partype in ["wave","adm"]:
        myfile.write('popleft:\t'+mypD+fh+"."+partype+"."+label+'.leftpop\n')
        if outgroup!="": myfile.write('popright:\t'+mypD+outgroup+'\n')
        else: myfile.write('popright:\t'+mypD+popfh+'.rightpop\n')
    
    myfile.close()
    return "Made %s PAR file" % partype+" "+mypD+fh+'.%s.' % partype +label+'.par'

def mklst(pD,fh,label,mylst,suffix=""):
    """
    
    Write text file with list of names, separated by '\n'. 
    Good to use for 'leftpop' and 'rightpop' in qpWave/qpAdm.
    
    pD       --  dir path for data files
    fh       --  filehandle for data files
    label    --  special label for file, the suffix will be added to this
    mylst    --  Python list of what to put in each line.
    suffix   --  Default 'txt' added to outname, can put 'leftpop' or 'rightpop'
    
    """
    if suffix != "": mysuf="."+suffix
    else: mysuf=""
    newfile=open(pD+fh+'.'+label+mysuf,'w')
    for i in mylst: newfile.write(i+'\n')
    newfile.close()
    return "Made %s%s.%s%s file" % (pD,fh,label,mysuf)