# FontFitColor (opensource)![image](https://user-images.githubusercontent.com/29166758/222115375-ee3f6f29-48ac-4fbe-b2d0-c30ad9664576.png)


This program is designed to substitute colored SVG-icons over existing TTF font glyphs.

Sometimes icons replace rarely used symbols of Western European alphabets or a font is created exclusively from icons, but for pnp (design and translate cards) it is more convenient to embed icons in the main font of the game. 
If you do not plan to replace glyphs, add new glyphs in the font editor in advance (FontForge, GlyphrStudio). 

For custom icons, it is recommended to use the unicode range E000:F8FF "Private Use Area".

The alternative program does not allow changing the size and position of glyphs.

https://apps.microsoft.com/store/detail/opentype-svg-font-editor/9NJ7K9JX60P1?hl=uk-ua&gl=ua&rtc=1

To simplify SVG, you can use this command line tool:

https://github.com/RazrFalcon/resvg/releases/download/v0.27.0/usvg-win64.zip

The project uses a revised SVG rendering library originally developed by Martin Walter.

https://development.mwcs.de/svgimage.html

Issue: used SVG-renderer cannot hande "mask" attrribute. Photoshop also displays them incorrectly.

Dmitry Yatsenko <yatcenko@gmail.com>
