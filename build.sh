mkdir build
rm -r build/html
cp -r html build
pico8 main.p8 -export "build/2048.bin -i 13 -s 2"
pico8 main.p8 -export "build/html/2048.js"
pico8 main.p8 -export "build/2048.p8.png"