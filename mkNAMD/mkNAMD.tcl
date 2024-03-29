# Usage: vmd -dispdev text -e mkNAMD.tcl -args builtPSF builtPDB outDir parDir simBoxX simBoxY simBoxZ namdFile simFile Temperature Dielectric Damping minimStep simStep setIMD sspVecs exb exbFile con conFile
# Generate a NAMD config file
# Author: Chen-Yu Li <cli56@illinois.edu>
# 2015/6/30
#

proc mkNAMD { builtPSF builtPDB outDir parDir simBoxX simBoxY simBoxZ namdFile simFile Temperature Dielectric Damping minimStep simStep setIMD sspVecs exb exbFile con conFile topoFile constPressure gridforce gridforceFile gridforcePotFile gridforceCont1 gridforceCont2 gridforceCont3 packNAMD} {
set argc 27
set argv {}

if {$packNAMD == 2} {
	set outDir ""
}

lappend argv $builtPSF
lappend argv $builtPDB
lappend argv $outDir
lappend argv $parDir
lappend argv $simBoxX 
lappend argv $simBoxY 
lappend argv $simBoxZ 
lappend argv $namdFile
lappend argv $Temperature
lappend argv $Dielectric
lappend argv $Damping
lappend argv $minimStep
lappend argv $simStep
lappend argv $setIMD
lappend argv $sspVecs
lappend argv $exb
lappend argv $exbFile
lappend argv $con
lappend argv $conFile
lappend argv $topoFile
lappend argv $simFile
lappend argv $packNAMD

if {$argc != 27} {
    puts "vmd -dispdev text -e mkNAMD.tcl -args psf pdb outDir parDir simBoxX simBoxY simBoxZ namdFile"
    puts "psf: psf file"
    puts "pdb: pdb file"
    puts "outDir: the directory to save simulation output"
    puts "parDir: the directory to find parameter files"
    puts "namdFile: final namdFile name"
    puts "Temperature: simulation temperature in Kelvin"
    puts "Dielectric: dielectric constant of the system"
    puts "Damping: langevin dynamics damping constant"

    exit
}

set psf [lindex $argv 0]
set pdb [lindex $argv 1]
set outDir [lindex $argv 2]
if {[string index $outDir end] == "/"} {set outDir [string trimright $outDir "/"]}
set parDir [lindex $argv 3]
if {[string index $parDir end] == "/"} {set parDir [string trimright $parDir "/"]}
set simBoxX   [lindex $argv 4]
set simBoxY   [lindex $argv 5]
set simBoxZ   [lindex $argv 6]

set id [mol load psf $psf pdb $pdb]
set all [atomselect top all]
set MinMax [measure minmax $all]
$all delete
#set x [expr [lindex $MinMax 1 0] - [lindex $MinMax 0 0]]
#set y [expr [lindex $MinMax 1 1] - [lindex $MinMax 0 1]]
#set z [expr [lindex $MinMax 1 2] - [lindex $MinMax 0 2]]
#set xvec [vecscale [lindex $sspVecs 0] $dimFactor]
#set yvec [vecscale [lindex $sspVecs 1] $dimFactor]
#set zvec [vecscale [lindex $sspVecs 2] $dimFactor]
set ovec [vecscale [lindex $sspVecs 3] 1]

set namdFile [open [lindex $argv 7] w]
set Temperature [lindex $argv 8]
set Dielectric [lindex $argv 9]
set Damping [lindex $argv 10]

if {$gridforceCont1} {
    set gridforceCont1 "on"
} else {
    set gridforceCont1 "off"
}
if {$gridforceCont2} {
    set gridforceCont2 "on"
} else {
    set gridforceCont2 "off"
}
if {$gridforceCont3} {
    set gridforceCont3 "on"
} else {
    set gridforceCont3 "off"
}


puts $namdFile "########################################################"
puts $namdFile "#### NAMD config file for simulating a box of water ####"
puts $namdFile "########################################################"
puts $namdFile ""
puts $namdFile "## USER VARIABLES"
puts $namdFile "set temperature  $Temperature"
puts $namdFile "#set mV           500"
puts $namdFile ""
puts $namdFile "# Continuing a job from the restart files"
puts $namdFile "# NOTE: \$base\$ii is not OK."
puts $namdFile "set base           $outDir/$simFile "
#puts $namdFile "set base           $outDir/sim0 "
puts $namdFile "set ii 0"
puts $namdFile "if {\[file exists \$base.\$ii.restart.coor\]} {"
puts $namdFile "   while {\[file exists \$base.\$ii.restart.coor\]} {"
puts $namdFile "      incr ii"
puts $namdFile "   }"
puts $namdFile "   set input          \$base.\[expr \$ii-1\].restart"
puts $namdFile "   bincoordinates     \$input.coor"
puts $namdFile "   binvelocities      \$input.vel"
puts $namdFile "   extendedSystem     \$input.xsc"
puts $namdFile "   set fd \[open \$input.xsc r\]"
puts $namdFile "   gets \$fd;  gets \$fd;  gets \$fd line"
puts $namdFile "   set ts \[lindex \$line 0\]"
puts $namdFile "   close \$fd"
puts $namdFile "   firsttimestep      \$ts"
puts $namdFile "} else {"
puts $namdFile "   cellBasisVector1                $simBoxX 0 0"
puts $namdFile "   cellBasisVector2                0 $simBoxY 0"
puts $namdFile "   cellBasisVector3                0 0 $simBoxZ"
puts $namdFile "   cellOrigin                      $ovec"
puts $namdFile "   temperature \$temperature"
puts $namdFile "   firsttimestep 0"
puts $namdFile "}"
puts $namdFile "outputName         \$base.\$ii"
puts $namdFile ""
puts $namdFile "################"
puts $namdFile "#### OUTPUT ####"
puts $namdFile "################"
puts $namdFile ""
puts $namdFile "## number of steps between output writes"
puts $namdFile "dcdfreq             	1200 ;# simulation trajectory"
puts $namdFile "restartfreq        	1200 ;# for restarting a simulation"
puts $namdFile "xstFreq             	1200 ;# log of simulation size"
puts $namdFile "outputEnergies      	1200 ;# info about the energy (printed in log file)"
puts $namdFile "outputPressure      	1200 ;# info about the pressure (printed in log file)"
puts $namdFile ""
puts $namdFile "###############"
puts $namdFile "#### INPUT ####"
puts $namdFile "###############"
puts $namdFile "structure   $psf ;# initial structure file"
puts $namdFile "coordinates $pdb ;# initial coordinate file"
puts $namdFile ""
puts $namdFile "COMmotion            no  ;# always (default is no and removes the center"
puts $namdFile "                         ;# of mass velocity whenever you restart a simulation"
puts $namdFile ""
puts $namdFile "################################"
puts $namdFile "#### THERMODYNAMIC ENSEMBLE ####"
puts $namdFile "################################"
puts $namdFile "if {1} {"
puts $namdFile "langevin          on        ;# temperature control with langevin thermostat"
puts $namdFile "                            ;# turn off for NVE"
puts $namdFile "langevinTemp      \$temperature"
puts $namdFile "langevinDamping   $Damping       ;# use weak coupling (0.01) during production simulations"
puts $namdFile "                            ;#   strong coupling (5.0) during equilibration simulations"
puts $namdFile "langevinHydrogen  off       ;# don't couple langevin bath to hydrogens"
puts $namdFile "}"
puts $namdFile ""
puts $namdFile "## temperature control with Lowe-Andersen thermostat (author's preference)"
puts $namdFile "#loweAndersen        on"
puts $namdFile "#loweAndersenTemp    \$temperature"
puts $namdFile ""
puts $namdFile "## perform constant pressure simulation"
puts $namdFile "if {$constPressure} { "
puts $namdFile "langevinPiston        on      ;# turn this off for constant volume sim"
puts $namdFile "langevinPistonTarget  1.01325 ;#  in bar -> 1 atm"
puts $namdFile "langevinPistonPeriod  1000.  "
puts $namdFile "langevinPistonDecay   500."
puts $namdFile "langevinPistonTemp    \$temperature"
puts $namdFile "}"
puts $namdFile ""
puts $namdFile "## additional "
puts $namdFile "useGroupPressure      yes ;# yes = don't"
puts $namdFile "                          ;# needed for rigidBonds (see rigidBonds below)"
puts $namdFile "useFlexibleCell       no  ;# allow x,y,z dimensions to fluctuate independently?"
puts $namdFile "useConstantArea       no  ;#   if so, fix area of xy-plane?"
puts $namdFile "# useConstantRatio      no  ;#   OR if so, fix aspect ratio of xy-plane?"
puts $namdFile ""
puts $namdFile "## affects output coordinates only, not dynamics"
puts $namdFile "wrapAll               off ;# since we use periodic boundary conditions we keep everything in one unit cell"
puts $namdFile "wrapWater             off ;# alternatively use 'wrapWater on' or comment out to leave system unwrapped"
puts $namdFile ""
puts $namdFile ""
puts $namdFile "###############################"
puts $namdFile "#### CALCULATION OF FORCES ####"
puts $namdFile "###############################"
puts $namdFile "## multiple timestepping: calculate some forces less frequently "
puts $namdFile "timestep	    2   ;# use 2fs timestep (for bonded interactions)"
puts $namdFile "                        ;# all the other 'frequencies' (really periods)"
puts $namdFile "                        ;#   are in terms of this"
puts $namdFile ""
puts $namdFile "nonBondedFreq	    1   ;# vdW and short range electrostatics every 2fs"
puts $namdFile "fullElectFrequency  2   ;# long range electrostatics every 6fs"
puts $namdFile "stepsPerCycle	    12  ;# re-evaluate parilistdist after this many steps"
puts $namdFile ""
puts $namdFile "margin              3"
puts $namdFile ""
puts $namdFile "## bonded interactions"
puts $namdFile "rigidBonds          all ;# freezes bond length between hydrogen and other atoms"
puts $namdFile "                        ;#   which is the fastest vibrational mode in an MD sim"
puts $namdFile "                        ;# holding this rigid allows 2fs timestep"
puts $namdFile "exclude             scaled1-4         ;# scale vdW interaction for bonded atoms"
puts $namdFile "1-4scaling          1.0               ;# use 0.833333333 for Amber parameters"
puts $namdFile ""
puts $namdFile "## short-range interactions"
puts $namdFile "switching	    on  ;# smoothly turn off vdW interactions at cutoff"
puts $namdFile "switchDist	    8   ;# start turning vdW interaction off (Å)"
puts $namdFile "cutoff		    10  ;# only calc short range interactions inside this (Å)"
puts $namdFile "pairlistdist	    12  ;# every stepPerCycle, each atom updates its list"
puts $namdFile "                        ;#   of atoms it may be interacting with during "
puts $namdFile "                        ;#   the following cycle, using this distance (Å)"
puts $namdFile ""
puts $namdFile "IMDon		$setIMD"
puts $namdFile "IMDport		2030"
puts $namdFile "IMDfreq		1"
puts $namdFile "IMDwait		on"
puts $namdFile ""
puts $namdFile "## long-range interactions (particle-mesh ewald for long-range electrostatics)"
puts $namdFile "#set pmeGrid 128# multiples of small integers are okay"
puts $namdFile "               ;# but best if a power of 2 (PME is costly to compute)"
puts $namdFile "               ;# Generally try for 1.25-1.75 Å / PME grid point"
puts $namdFile ""
puts $namdFile "PmeGridSpacing	    1.2  ;# this is larger than the usual number"
puts $namdFile "PME                 yes"
puts $namdFile "#PMEGridSizeX        50"
puts $namdFile "#PMEGridSizeY        110"
puts $namdFile "#PMEGridSizeZ        110"
puts $namdFile "dielectric $Dielectric"
puts $namdFile ""
puts $namdFile "## Force-Field Parameters"
puts $namdFile "paraTypeCharmm  on  # we always use CHARMM formatted parameters (even when using Amber)"
# Add paramter files
set parFiles [glob -nocomplain -- $parDir/*.prm]
set parFiles [list {*}$parFiles {*}[glob -nocomplain -- $parDir/*.par]]
set parFiles [list {*}$parFiles {*}[glob -nocomplain -- $parDir/*.str]]
set parFiles [list {*}$parFiles {*}[glob -nocomplain -- $parDir/*.inp]]
set parFiles [list {*}$parFiles {*}[glob -nocomplain -- $topoFile]]

foreach par $parFiles {
	if { $packNAMD == 2} {
		set parr [lindex [file split $par] end]
		set par "/topology/$parr"
	}
    puts $namdFile "parameters      $par"
}

puts $namdFile "##############"
puts $namdFile "#### MISC ####"
puts $namdFile "##############"
puts $namdFile "## parallel performance enhancing parameters for supercomputing clusters"
puts $namdFile "##   (comment out for local use)"
puts $namdFile "# ldbUnloadZero			yes"
puts $namdFile "# twoAwayX			no"
puts $namdFile "# twoAwayY			no"
puts $namdFile "# twoAwayZ			no"
puts $namdFile ""
puts $namdFile "#########################"
puts $namdFile "#### EXTERNAL FORCES ####"
puts $namdFile "#########################"
puts $namdFile ""
puts $namdFile ""
puts $namdFile "## SMD"
puts $namdFile "if {0} {"
puts $namdFile "SMD                             on"
puts $namdFile "SMDFile                         constrain/square2plate_1MKCl_reduce_Mg3_DNAConstrain.pdb"
puts $namdFile "SMDk                            1"
puts $namdFile "SMDVel                          0"
puts $namdFile "SMDDir                          0 0 1"
puts $namdFile "SMDOutputFreq                   48"
puts $namdFile "}"
puts $namdFile ""
puts $namdFile ""
puts $namdFile "##fix atoms"
puts $namdFile "#fixedAtoms     on"
puts $namdFile "#fixedAtomsFile constrain/square5nmPore-WLI-DNAfix.pdb"
puts $namdFile "#fixedAtomsCol  B"
puts $namdFile ""
puts $namdFile "## e-Field"
puts $namdFile "if {0} {"
puts $namdFile "source /u/sciteam/cli56/scripts/Procs.tcl"
puts $namdFile "set xsc \$input.xsc "
puts $namdFile "set xs                          \[readExtendedSystem \$xsc\]"
puts $namdFile "set zfield                      \[expr \$mV * 0.023045 / \[lindex \$xs 9\]\]"
puts $namdFile "eFieldOn                        on"
puts $namdFile "eField                          0.0 0.0 \$zfield;  #kcal/(mol angstron e)"
puts $namdFile "                                                      #1V/A = 23.0451 kcal/(mol angstron e)"
puts $namdFile "}"
puts $namdFile "## TCLforces"
puts $namdFile "## etc."
puts $namdFile "if {$gridforce} {"
puts $namdFile "gridforce                       on"
puts $namdFile "gridforceFile                   $gridforceFile"
puts $namdFile "gridforceCol                    B"
puts $namdFile "gridforceChargeCol              O"
puts $namdFile "gridforcePotFile                $gridforcePotFile"
puts $namdFile "gridforceScale                  2 2 2"
puts $namdFile "gridforceCont1                  $gridforceCont1"
puts $namdFile "gridforceCont2                  $gridforceCont2"
puts $namdFile "gridforceCont3                  $gridforceCont3"
puts $namdFile "}"
puts $namdFile ""
puts $namdFile ""
puts $namdFile "##ExcludeFromPressure"
puts $namdFile "#ExcludeFromPressure        on"
puts $namdFile "#ExcludeFromPressureFile    constrain/square4plate-1MKCl-DNAconstrain.pdb"
puts $namdFile "#ExcludeFromPressureCol     B"
puts $namdFile ""
puts $namdFile ""
puts $namdFile "## harmonic restraints"
puts $namdFile "if {$con} {"
puts $namdFile "constraints     on"
puts $namdFile "consref         $conFile"
puts $namdFile "conskfile       $conFile"
puts $namdFile "conskcol        B"
puts $namdFile "}"
puts $namdFile ""
puts $namdFile ""
puts $namdFile "##Extrabonds for MGHH stability"
puts $namdFile "if {$exb} {"
puts $namdFile "extraBonds      on"
puts $namdFile "extraBondsFile  $exbFile"
puts $namdFile "}"
puts $namdFile ""
puts $namdFile "##Constraining atoms of DNA bases using elastic networks"
puts $namdFile "#extraBonds      on "
puts $namdFile "#extraBondsFile  extrabonds.enm.init"
puts $namdFile ""
puts $namdFile ""
puts $namdFile "#############"
puts $namdFile "#### RUN ####"
puts $namdFile "#############"
puts $namdFile ""
puts $namdFile "if {\$ii == 0} {"
puts $namdFile "    minimize $minimStep "
puts $namdFile "} else {"
puts $namdFile "    run $simStep "
puts $namdFile "}"
puts $namdFile "#exit"
puts $namdFile "# remove clashes from introduced during system assembly"
puts $namdFile ""
puts $namdFile "## after minimization, there will be 0 kinetic energy, and all potentials are at a local minimum"
puts $namdFile "## this loop injects energy into the system ten times to quickly bring the temperature up to \$temperature"
puts $namdFile "#for {set i 0} {\$i < 4} {incr i} { "
puts $namdFile "#    run 480"
puts $namdFile "#    reinitvels \$temperature"
puts $namdFile "#}"
puts $namdFile "# simulate for a while (must be multiple of stepsPerCycle)"
puts $namdFile "            # 0.96 ns"

close $namdFile

}
