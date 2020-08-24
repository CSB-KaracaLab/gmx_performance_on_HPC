$gmx make_ndx -f complex-solvated.gro <<EOD
1|12|13
EOD
#creates an index file to examine Protein_DNA_SAM and Water_and_ions seperately

$gmx grompp -v -f 02_em_sol_PME.mdp -c complex-solvated.gro -p complex.top -o complex-EM-solvated.tpr
$gmx  mdrun -v -deffnm complex-EM-solvated
#minimizes the solvated system

$gmx grompp -v -f 03_nvt_pr1000_PME.mdp -c complex-EM-solvated.gro -r complex-EM-solvated.gro -p complex.top -n index.ndx -o complex-NVT-PR1000.tpr
$gmx mdrun -v -deffnm complex-NVT-PR1000
#Injects temperature to the system at constant volume with position restraints 

$gmx grompp -v -f 04_npt_pr_PME.mdp -c complex-NVT-PR1000.gro -r complex-NVT-PR1000.gro -p complex.top -n index.ndx -o complex-NPT-PR1000.tpr
$gmx mdrun -v -deffnm complex-NPT-PR1000
#Switches to constant pressure condition with position restraint

cp posre_DNA_chain_X.itp posre_DNA_chain_X.itp.1000 ; cp posre_DNA_chain_Y.itp posre_DNA_chain_Y.itp.1000 ; cp posre_Protein_chain_A.itp posre_Protein_chain_A.itp.1000 ;  cp posre_Protein_chain_B.itp posre_Protein_chain_B.itp.1000 ;  cp posre_SAM.itp posre_SAM.itp.itp.1000 
sed -i -e 's/1000 1000 1000/100 100 100/g' posre_DNA_chain_X.itp ;  sed -i -e 's/1000 1000 1000/100 100 100/g' posre_DNA_chain_Y.itp ;  sed -i -e 's/1000 1000 1000/100 100 100/g' posre_Protein_chain_A.itp ;  sed -i -e 's/1000 1000 1000/100 100 100/g' posre_Protein_chain_B.itp ;  sed -i -e 's/1000 1000 1000/100 100 100/g' posre_SAM.itp
#decreases the position restraint by 10 fold

$gmx grompp -v -f 04_npt_pr_PME.mdp -c complex-NPT-PR1000.gro -r complex-NPT-PR1000.gro -p complex.top -n index.ndx -o complex-NPT-PR100.tpr
$gmx mdrun  -v -deffnm complex-NPT-PR100
#Readjusts the MD at constant P

cp posre_DNA_chain_X.itp posre_DNA_chain_X.itp.100 ;  cp posre_DNA_chain_Y.itp posre_DNA_chain_Y.itp.100 ;  cp posre_Protein_chain_A.itp posre_Protein_chain_A.itp.100 ;  cp posre_Protein_chain_B.itp posre_Protein_chain_B.itp.100 ; cp posre_SAM.itp posre_SAM.itp.100
sed -i -e 's/100 100 100/10 10 10/g' posre_DNA_chain_X.itp ; sed -i -e 's/100 100 100/10 10 10/g' posre_DNA_chain_Y.itp ;  sed -i -e 's/100 100 100/10 10 10/g' posre_Protein_chain_A.itp ;  sed -i -e 's/100 100 100/10 10 10/g' posre_Protein_chain_B.itp ;  sed -i -e 's/100 100 100/10 10 10/g' posre_SAM.itp
#decreases the position restraint by 10 fold

$gmx grompp -v -f 04_npt_pr_PME.mdp -c complex-NPT-PR1000.gro -r complex-NPT-PR100.gro -p complex.top -n index.ndx -o complex-NPT-PR10.tpr
$gmx mdrun -v -deffnm complex-NPT-PR10
#Readjusts the MD at constant P

$gmx grompp -v -f 05_npt_NOpr_PME.mdp -c complex-NPT-PR10.gro -p complex.top -n index.ndx -o complex-NPT-noPR.tpr
$gmx mdrun -v -deffnm complex-NPT-noPR
#Releases all the position restraints

