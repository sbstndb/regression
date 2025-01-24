#!/bin/bash

# Déclaration des versions LLVM à utiliser
llvm_versions=("16" "18")  # Modifier avec les versions souhaitées
gcc_versions=("10" "11" "14")



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

for version in "${llvm_versions[@]}"; do
    echo "Chargement LLVM $version..."
    spack load llvm@"$version"
    
    echo "Création du dossier build-$version"
    mkdir -p "build-llvm-$version"
    cd "build-llvm-$version"
    
    echo "Compilation..."
    cmake -DXBENCHMARK_USE_XTENSOR=ON ..
    make -j
    
    cd ..

    spack unload llvm@"$version"
done

for version in "${gcc_versions[@]}"; do
    echo "Chargement GCC $version..."
    spack load gcc@"$version"
    
    echo "Création du dossier build-$version"
    mkdir -p "build-gcc-$version"
    cd "build-gcc-$version"
    
    echo "Compilation..."
    cmake -DXBENCHMARK_USE_XTENSOR=ON ..
    make -j
    
    spack unload gcc@"$version"
    cd ..
done


# Exécution des benchmarks pour chaque version
for version in "${llvm_versions[@]}"; do
    echo "Exécution avec LLVM $version"
    cd "build-llvm-$version"
    
    for exe in "${executables[@]}"; do
#        if [ -f "$exe" ]; then
	echo $(pwd)/${exe}
            echo "Lancement de $exe"
	    taskset -c 2 $(pwd)/"$exe" --benchmark_min_time=0.1s --benchmark_out_format=json --benchmark_out=llvm_${version}_$(basename ${exe}).json  # Ajouter les options réelles
#        else
#            echo "ERREUR: $exe non trouvé dans build-llvm-$version"
#        fi
    done
    
    cd ..
done


for version in "${gcc_versions[@]}"; do
    echo "Exécution avec GCC $version"
    cd "build-gcc-$version"
    
    for exe in "${executables[@]}"; do
#        if [ -f "$exe" ]; then
        echo $(pwd)/${exe}
            echo "Lancement de $exe"
            taskset -c 2 $(pwd)/"$exe" --benchmark_min_time=0.1s --benchmark_out_format=json --benchmark_out=gcc_${version}_$(basename ${exe}).json  # Ajouter les options réelles
#        else
#            echo "ERREUR: $exe non trouvé dans build-llvm-$version"
#        fi
    done

    cd ..
done



