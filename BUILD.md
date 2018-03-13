
FILE=top

DEPS="debouncer.v program.v"
MEMORY="1k"

yosys -p "synth_ice40 -blif $FILE.blif" -q $FILE.v $DEPS &&
    arachne-pnr -d $MEMORY -p $FILE.pcf $FILE.blif -o $FILE.txt && 
    icepack $FILE.txt $FILE.bin

# Upload to device
iceprog $FILE.bin


