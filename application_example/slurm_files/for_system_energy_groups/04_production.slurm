#!/bin/bash
#SBATCH -p barbun-cuda  			; name of the computing cluster                                                                           
#SBATCH -A bsavas       			; name of the account
#SBATCH -J barbun_2020_sys                      ; name of the job
#SBATCH --nodelist=barbun137                    ; specific node you want, if required           
#SBATCH -N 1                                    ; node number you want to use
#SBATCH -n 40					; CPU numbers you want to use
#SBATCH --time=1-00:00:0			; Time amount you need to complete your job. Maximum 15 days
#SBATCH --gres=gpu:1				; GPU number you want to use
#SBATCH --mail-type=ALL                         ; mail types you want to get i.e begin, end, fail, requeue
#SBATCH --mail-user=buusrasavas@gmail.com       ; mail address
#SBATCH --output=complex-%j.out                 ; name of the output file
#SBATCH --error=complex-%j.err		        ; name of the error file

source /etc/profile.d/modules.sh
module load centos7.3/app/gromacs/2020-impi-mkl-PS2018-GOLD-CUDA
module load  centos7.3/lib/cuda/10.0

module load centos7.3/lib/openmpi/1.8.8-gcc-4.8.5
module load centos7.3/lib/acml/6.1.0-gfortan64

export OMP_NUM_THREADS=20
echo "SLURM_NODELIST $SLURM_NODELIST"
echo "NUMBER OF CORES $SLURM_NTASKS"

$GROMACS_DIR/bin/gmx_mpi grompp -v -f 06_md_PME.mdp -c complex-NPT-noPR.gro -p complex.top -o complex_md.tpr  -r complex-NPT-noPR.tpr
$GROMACS_DIR/bin/gmx_mpi mdrun -v -deffnm complex_md -pin on

exit
