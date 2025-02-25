#!/bin/bash -fv 


f2py HumanIndexMod.F90 -m HumanIndexMod -h HumanIndexMod.pyf
f2py -c HumanIndexMod.pyf HumanIndexMod.F90

f2py HumanIndexModOld.F90 -m HumanIndexModOld -h HumanIndexModOld.pyf
f2py -c HumanIndexModOld.pyf HumanIndexModOld.F90

