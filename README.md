# TM4C123G
Template code for the Tiva TM4C123G ARM Cortex m4 board

#DEPENDENCIES
You first need to install lm4flash
`git clone https://github.com/utzig/lm4tools.git`
`cd lm4tools/lm4flash/`
`make`
`sudo cp lm4flash /usr/bin/`

You then need no install OpenOCD with ICDI support
`git clone git://git.code.sf.net/p/openocd/code`
`cd openocd.git`
`./bootstrap`
`./configure --prefix=/usr --enable-maintainer-mode --enable-stlink --enable-ti-icdi`
`make`
`sudo make install`
