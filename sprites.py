#!usr/bin/python

import os
import PIL.Image


def convertImage(root: str, filename: str) -> bool:
    origPath = os.path.join(root, filename)
    filename = filename.split('.')[0]
    new_name = f"{filename}.spr"
    path = os.path.join(root, new_name)

    image = PIL.Image.open(origPath)
    image = image.convert("RGBA")

    width, height = image.size
    with open(path, 'w') as f:

        f.write(f"SPR_{filename.upper()}: .word\n")
        for j in range(height):
            for i in range(width):
                px = image.getpixel((i, j))
                if px[3] < 255:
                    f.write(f"0x00{px[0]:02x}{px[1]:02x}{px[2]:02x} ")
                else:
                    f.write(f"0xff{px[0]:02x}{px[1]:02x}{px[2]:02x} ")
            f.write('\n')

    return True


def main() -> None:
    sprites = os.path.join(os.getcwd(), "sprites")
    for file in os.listdir(sprites):
        if (file.split('.')[1] == 'spr'):
            continue

        if (convertImage(sprites, file)):
            print(f"Converted file {os.path.basename(file)}.")
        else:
            print(f"FAILED to convert file {os.path.basename(file)}.")
    pass


if __name__ == '__main__':
    main()
