# This script is expected to extract certain information from an output file of
# Gaussian 16 to prepare for supporting information of a manuscript. The freq 
# keyword should apppear in the corresponding input file.
# Usage:
# awk -f g16optlog.awk output.log output.log

BEGIN {
thermalflag = 0;
numimaginaryfreq = 0;
}

FNR == NR {
if (NF == 2 && $1 == "Symbolic" && $2 == "Z-matrix:")
    elementsstart = FNR + 2;
if (NF == 6 && $1 == "Rotational" && $2 == "temperatures" && $3 == "(Kelvin)")
{
    thermalflag = 1;
    elementsend = elementsstart + coordinatesend - coordinatesstart
}
if (NF == 2 && $1 == "Standard" && $2 == "orientation:")
    coordinatesstart = FNR + 5;
if (thermalflag == 0 && NF == 6 && $1 == "Rotational" && $2 == "constants" && $3 == "(GHZ):")
    coordinatesend = FNR - 2;
if (NF == 7 && $1 == "******" && $2 == "1" && $3 == "imaginary" && $4 == "frequencies" && $5 == "(negative" && $6 == "Signs)" && $7 == "******")
{
    numimaginaryfreq = 1;
    lineimaginaryfreq = FNR + 9;
}
if (numimaginaryfreq == 1 && FNR == lineimaginaryfreq && NF == 5 && $1 == "Frequencies" && $2 == "--")
    freq = $3;
if (NF == 5 && $1 == "Thermal" && $2 == "correction" && $3 == "to" && $4 == "Enthalpy=")
    printf("Thermal correction to enthalpy (a.u.):          %s\n", $5);
if (NF == 7 && $1 == "Thermal" && $2 == "correction" && $3 == "to" && $4 == "Gibbs" && $5=="Free" && $6=="Energy=")
{
    if (numimaginaryfreq == 0)
	    printf("Thermal correction to Gibbs free energy (a.u.): %s\n\nCartesian coordinates:\nATOM         X         Y         Z\n", $7);
    else
	    printf("Thermal correction to Gibbs free energy (a.u.): %s\nImaginary frequency: %.4f cm-1\n\nCartesian coordinates:\nATOM         X         Y         Z\n", $7, freq);
    nextfile;
}
}

FNR < NR {
if (FNR >= elementsstart && FNR <= elementsend)
    atom[FNR-elementsstart] = $1;
if (FNR >= coordinatesstart && FNR <= coordinatesend)
    printf("%-4s%10.6f%10.6f%10.6f\n", atom[FNR-coordinatesstart], $4, $5, $6);
if (FNR > coordinatesend)
    exit 0;
}
