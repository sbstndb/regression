#!/bin/bash


# Liste des exécutables à lancer
executables=(
	"src/view/view_stride" 
	"src/view/view_all" 
	"src/blas1/blas1_add_scalar" 
	"src/blas1/blas1_fma"
	"src/blas1/blas1_simple_operation"
	"src/blas1/blas1_logic")  # Remplacer avec vos binaires

# Création des dossiers et compilation pour chaque version
#
#
spack load xtensor@0.25%gcc@14

spack load llvm@18
for use_xsimd in ON OFF; do
    echo "Chargement LLVM $version..."
    
    echo "Création du dossier build-llvm-xsimd-$use_xsimd"
    mkdir -p "build-llvm-xsimd-$use_xsimd"
    cd "build-llvm-xsimd-$use_xsimd"
    
    echo "Compilation..."
    cmake -DXBENCHMARK_USE_XTENSOR=ON -DXTENSOR_USE_XSIMD=$use_xsimd ..
    make -j
    
    cd ..

done
spack unload llvm

spack load gcc@14
for use_xsimd in ON OFF; do
    echo "Chargement GCC $version..."
    
    echo "Création du dossier build-gcc-xsimd-$use_xsimd"
    mkdir -p "build-gcc-xsimd-$use_xsimd"
    cd "build-gcc-xsimd-$use_xsimd"
    
    echo "Compilation..."
    cmake -DXBENCHMARK_USE_XTENSOR=ON -DXTENSOR_USE_XSIMD=$use_xsimd .. 
    make -j
    
    cd ..

done




# Exécution des benchmarks pour chaque version
for use_xsimd in ON OFF; do
    echo "Exécution avec LLVM $use_xsimd"
    cd "build-llvm-xsimd-$use_xsimd"
    
    for exe in "${executables[@]}"; do
#        if [ -f "$exe" ]; then
	echo $(pwd)/${exe}
            echo "Lancement de $exe"
	    taskset -c 2 $(pwd)/"$exe" --benchmark_min_time=0.1s --benchmark_out_format=json --benchmark_out=llvm_${use_xsimd}_$(basename ${exe}).json  # Ajouter les options réelles
#        else
#            echo "ERREUR: $exe non trouvé dans build-llvm-$version"
#        fi
    done
    
    cd ..
done


# Exécution des benchmarks pour chaque version
for use_xsimd in ON OFF; do
    echo "Exécution avec GCC $use_xsimd"
    cd "build-gcc-xsimd-$use_xsimd"
    
    for exe in "${executables[@]}"; do
#        if [ -f "$exe" ]; then
        echo $(pwd)/${exe}
            echo "Lancement de $exe"
            taskset -c 2 $(pwd)/"$exe" --benchmark_min_time=0.1s --benchmark_out_format=json --benchmark_out=gcc_${use_xsimd}_$(basename ${exe}).json  # Ajouter les options réelles
#        else
#            echo "ERREUR: $exe non trouvé dans build-llvm-$version"
#        fi
    done
    
    cd ..
done





