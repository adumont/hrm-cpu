
FILE=top

DEPS="debouncer.v program.v"
MEMORY="1k"

yosys -p "synth_ice40 -blif $FILE.blif" -q $FILE.v $DEPS &&
    arachne-pnr -d $MEMORY -p $FILE.pcf $FILE.blif -o $FILE.txt && 
    icepack $FILE.txt $FILE.bin

# Upload to device
iceprog $FILE.bin



yosys -p "prep -top $FILE; write_json $FILE.json" $FILE.v $DEPS

(install nodejs)
git clone https://github.com/nturley/netlistsvg
cd netlistsvg
npm install

node bin/netlistsvg input_json_file [-o output_svg_file] [--skin skin_file]

node ~/opt/netlistsvg/bin/netlistsvg.js $FILE.json -o assets/$FILE.svg --skin ~/opt/netlistsvg/lib/default.svg

inkview assets/$FILE.svg

https://github.com/nturley/netlistsvg

DEMO: https://nturley.github.io/netlistsvg/
