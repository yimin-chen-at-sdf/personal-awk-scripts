# This script is expected to modify Gaussian input files for SMD18 calculation.
# If you do not want to modify memory requirements or specify number of proces-
# sors, you can run the following command:
# awk -f smd18.awk input.com input.com
# If you want to set the memory as 256 GB and require 64 cores, you can run the
# following command:
# awk -f smd18.awk -v m=256 -v n=64 input.com input.com

BEGIN {
flag1 = 0;
flag2 = 0;
flag3 = 0;
}

FNR == NR {
if (flag1 > 0 && FNR > flag1 + 4 && NF == 4 && flag2 == 0)
    flag2 = FNR;
if (flag1 > 0 && FNR > flag1 + 4 && NF != 4 && flag2 > 0)
{
    flag3 = FNR - 1;
    nextfile;
}
if (substr($1,1,1) == "#")
    flag1 = FNR;
}

FNR < NR {
if (FNR < flag2)
{
    if (FNR == flag1)
        printf("#P M06/genecp scrf(SMD,solvent=n,n-DiMethylFormamide,read)\n");
    else if (substr($1,1,4) == "%mem")
    {
        if ((m=="") && (m==0))
            print $0;
        else
            printf("%mem=%dGB\n", m);
    }
    else if (substr($1,1,12) == "%nprocshared")
    {
        if ((n=="") && (n==0))
            print $0;
        else
            printf("%nprocshared=%d\n", n);
    }
    else
        print $0;
}
if (FNR >= flag2)
{
    if (FNR <= flag3)
        print $0;
    else
    {
        printf("\n@/sob/SMD18.gbs/N\n\n@/sob/def2-ECP.txt/N\n\nmodifysph\n\nI 2.74\nBr 2.60\n\n\n");
        exit 0;
    }
}
}
