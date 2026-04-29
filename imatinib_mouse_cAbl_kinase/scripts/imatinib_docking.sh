#!usr/bin/env bash

##Installation
conda create -n vina python=3
conda activate vina
conda config --env --add channels conda-forge
conda install -c conda-forge numpy swig boost-cpp libboost sphinx sphinx_rtd_theme
pip install vina
pip install -U scipy rdkit meeko gemmi prody
conda install -c conda-forge autogrid

###Turns out vina wasn't installed and I ran into conflicts due to Python 3.14 :(
#Create a separate conda environment for vina
conda create -n vina_dock python=3.11
conda activate vina_dock
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --set channel_priority strict
conda install vina

#Prepare the receptor for docking: remember to remove the ligands prior to running this
mk_prepare_receptor.py -i data/1IEP_clean_receptor.pdb -o output/1IEP_prep_receptor -p -v \
  --box_size 20 20 20 --box_center 15.190 53.903 16.917

#View the coordinates
cat 1IEP_prep_receptor.box.txt

#Prepare the ligand for docking. Download the SDF format of imatinib from Pubchem: https://pubchem.ncbi.nlm.nih.gov/compound/5291
mk_prepare_ligand.py -i data/imatinib_ligand_COMPOUND_CID_5291.sdf -o output/imatinib_ligand.pdbqt

#Docking
vina --receptor output/1IEP_prep_receptor.pdbqt --ligand output/imatinib_ligand.pdbqt \
  --config output/1IEP_prep_receptor.box.txt \
  --exhaustiveness=32 \
  --out output/1IEP_ligand_vina_out.pdbqt

#Export the results to SDF
mk_export.py output/1IEP_ligand_vina_out.pdbqt -s output/1IEP_ligand_vina_out.sdf
