# gmx_performance_on_HPC
Gromacs performance benchmarking on different HPC platforms


STEP #1 - Establishing a connection to TRUBA

How to install Tunnelblick for Mac users:
1) Download suitable version of Tunnelblick from the link. (beta version is suitable for most users.)
https://tunnelblick.net/downloads.html
2)Follow installing instructions from the link.
https://tunnelblick.net/cInstall.html#downloading-tunnelblick-and-verifying-the-download
3)After completing installation, tunnelblick icon will be appear on the top right corner. 
How to connect TRUBA via Tunnelblick:
Required to use TRUBA-genel.tblk.zip folder to connect TRUBA.
1)Unzip the folder.
2)Double click on Truba-genel.tblk folder. (It should appear as Tunnelblick package)
3)Enter the user name with the host name (username@hostname) and then the password.
4)Now you're connected to the TRUBA.

STEP #2 - Setting the right environment variable to run things interactively
(This should be only for testing purposes, never run something heavy on the login node)

As of 2020-04-09 Gromacs 2020 is installed on Barbun
To test things with Gromacs 2020, first ssh to barbun.yonetim (while you are already logged into levrek1)
> ssh 172.16.11.1

Then:
> source /truba/sw/centos7.3/comp/intel/PS2018-update2/bin/compilervars.sh intel64
> module load centos7.3/comp/cmake/3.10.1
> module load centos7.3/comp/gcc/6.4

This will set the right environment to call Gromacs 2020 on TRUBA
If you use bash
> export gmx=/truba/sw/centos7.3/app/gromacs/2020-impi-mkl-PS2018-GOLD/bin/gmx
If you use csh
> set gmx=/truba/sw/centos7.3/app/gromacs/2020-impi-mkl-PS2018-GOLD/bin/gmx

This will allow you to call Gromacs 2020 as $gmx

You an include these lines also in your .bashrc or .cshrc profiles


# How to set a protein-dna-SAM complex simulation with Gromacs 2020 on TRUBA (barbun)
# compiled by Ezgi Karaca 2020-04-08
# The reference pdb to be simulated: 6F57
# SAM parameters are taken from the literature (provided by Deniz Dogan)
# NOTE that GPU support won't be active until reaching the very final MD step

1) Take the starting structure (without SAM) --> complex.pdb
SAM.gro & SAM.itp & posre_SAM.itp files should also be provided with this instructions
This should be done as SAM is not a standard molecule to be recognized by the FF

2) sbatch generate-initial-gro.slurm
This command will generate gro and itp files (topology and parameter files)
In this slurm script #SBATCH --nodelist=barbun137 parameter should be changed to any idle barbun node

3) In this special case, we need to edit conf.gro manually:
	i - to cap the charge at the beginning and the end of each DNA chain
	ii - to include SAM (small molecule) parameters that are calculated externally
	iii - include the relevant topology parameters according to SAM addition

Step i: The termini of the DNA chains are (please inspect complex.gro)
chain Y: 365DC (5') & 374DT (3') -- they should be changed to 365DC5 & 374DT3
chain X: 355DA (5') & 364DG3 (3') -- they should be changed to 355DA5 & 364DG3
These definitions are found in amber14sb_parmbsc1.ff/dna.rt

Step ii: Paste the SAM gro coordinates at the end of complex.gro file (before the final line)
Update the number of atoms that are in the header of the gro file accordingly (8643 to 8693)
Upate the atom numbers of SAM so that the numbers are consecutive

Step iii: Add the following lines
; Include ligand top
#include "SAM.itp"

Also, at the end of the file, include
SAM                 1

4) The submit 02_solvate_vacuum_minim.slurm to start the vacuum minimization
At the end of this run check the generated pdb files whether all is OK
Beware that this script adds the ions to SOL (no# 17)

5) Check how many ions are added into the system by (this changes each time):

grep "NA+" complex-solvated.gro  | wc -l
152
grep "CL-" complex-solvated.gro  | wc -l
140
grep "OW" complex-solvated.gro  | grep SOL | wc -l
47302

These numbers should be updated in the topology file (at the end)

6) Create an index file to define Protein_DNA_SAM and Water_and_ions as separate objects
Update mdp files where energygrps and tc-grps are defined
Protein Non-Protein --> Protein_DNA_SAM Water_and_ions

5) This is followed by 03_mdrun_after_top_edit.slurm script
	For this section don't forget to update 03_nvt_pr1000_PME.mdp:gen_seed
	
6) To extract pdb file on the go:
$gmx trjconv -f complex_md.xtc -s complex_md.tpr -o complex_md.pdb -pbc nojump -dt 500 -n index.ndx