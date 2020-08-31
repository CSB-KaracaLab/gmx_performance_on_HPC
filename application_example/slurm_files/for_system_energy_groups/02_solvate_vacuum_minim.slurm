$gmx editconf -f complex.gro -o complex-PBC.gro -bt dodecahedron -c -d 1.4
#generates a box around the molecule

$gmx grompp -v -f 01_em_vac_PME.mdp -c complex-PBC.gro -p complex.top -o complex-EM-vacuum.tpr -maxwarn 1
$gmx editconf -f complex-PBC.gro -o complex-PBC.pdb
$gmx mdrun -ntmpi 1  -ntomp 20 -v -deffnm complex-EM-vacuum
$gmx editconf -f complex-EM-vacuum.gro -o complex-EM-vacuum.pdb
# minimizes the molecule in vacuum

$gmx solvate -cp complex-EM-vacuum.gro -cs spc216.gro -o complex-water.gro -p complex.top
$gmx editconf -f complex-water.gro -o complex-water.pdb
#solvates the simulation box 

$gmx grompp -v -f 02_em_sol_PME.mdp -c complex-water.gro -p complex.top -o complex-water.tpr -maxwarn 1
$gmx genion -s complex-water.tpr -o complex-solvated.gro -conc 0.15 -neutral -pname K -nname CL <<EOD
17
EOD
#adds ions to your system