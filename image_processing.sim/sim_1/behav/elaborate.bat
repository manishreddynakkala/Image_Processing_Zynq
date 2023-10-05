@echo off
set xv_path=C:\\Xilin\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto 7d4491dee20d4c17a79b49c274a5c727 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L fifo_generator_v13_1_3 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot tb_behav xil_defaultlib.tb xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
