mkdir -p work
ghdl -i --workdir=work --std=08 *.vhdl
ghdl -m --workdir=work --std=08 fetch_tb
ghdl -r --workdir=work --std=08 fetch_tb --wave=wave.ghw --assert-level=note
# gtkwave wave.ghw