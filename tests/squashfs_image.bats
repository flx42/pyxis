#!/usr/bin/env bats

load ./common

function setup() {
    rm -f *.sqsh || true
    enroot remove -f pyxis-squashfs-test || true
}

function teardown() {
    rm -f *.sqsh || true
    enroot remove -f pyxis-squashfs-test || true
}

@test "Ubuntu 18.04 squashfs" {
    run_enroot import -o ubuntu.sqsh docker://ubuntu:18.04
    run_srun --container-image=./ubuntu.sqsh grep 'Ubuntu 18.04' /etc/os-release
}

@test "import - export - import" {
    run_enroot import -o ubuntu.sqsh docker://ubuntu:18.04
    run_srun --container-image=./ubuntu.sqsh --container-name=pyxis-squashfs-test sh -c 'apt-get update && apt-get install -y file'
    run_srun --container-name=pyxis-squashfs-test sh -c 'echo pyxis > /test'
    run_enroot export -o ubuntu-modified.sqsh pyxis-squashfs-test
    run_srun --container-image=./ubuntu-modified.sqsh which file
    run_srun --container-image=./ubuntu-modified.sqsh cat /test
    [ "${lines[-1]}" == "pyxis" ]
}

@test "--container-save absolute path" {
    readonly image="$(pwd)/ubuntu-modified.sqsh"
    run_srun --container-image=ubuntu:20.04 --container-save=${image} sh -c 'echo pyxis > /test'
    run_srun --container-image=${image} --container-save=${image} sh -c 'echo slurm > /test2'
    run_srun --container-image=${image} --container-save=${image} sh -c 'apt-get update && apt-get install -y file'
    run_srun --container-image=${image} which file
    run_srun --container-image=${image} cat /test
    [ "${lines[-1]}" == "pyxis" ]
    run_srun --container-image=${image} cat /test2
    [ "${lines[-1]}" == "slurm" ]
}

@test "--container-save relative path" {
    readonly image="./ubuntu-modified.sqsh"
    run_srun --container-image=ubuntu:20.04 --container-save=${image} sh -c 'echo pyxis > /test'
    run_srun --container-image=${image} --container-save=${image} sh -c 'echo slurm > /test2'
    run_srun --container-image=${image} --container-save=${image} sh -c 'apt-get update && apt-get install -y file'
    run_srun --container-image=${image} which file
    run_srun --container-image=${image} cat /test
    [ "${lines[-1]}" == "pyxis" ]
    run_srun --container-image=${image} cat /test2
    [ "${lines[-1]}" == "slurm" ]
}
