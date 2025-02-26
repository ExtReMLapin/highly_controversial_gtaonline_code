import cv2
import numpy as np

#load image image.jpg

img = cv2.imread('image.jpg')

width = img.shape[1]
height = img.shape[0]


subimg_width = 206
subimg_height = 231

images = []
c = 0


def isFemale(index):
    if index < 21 or index > 41:
        return False
    return True




male_lightest = None
male_darkest = None

female_lightest = None
female_darkest = None

for j in range(0, height, subimg_height):
    for i in range(0, width, subimg_width):

        subimg = img[j:j+subimg_height, i:i+subimg_width]

        crop_x = 67
        crop_y = 39
        w_h = 24
        if c >= 45:
            break

        crop_subimg = subimg[crop_y:crop_y+w_h, crop_x:crop_x+w_h]
        luminosity = np.average(crop_subimg)

        images.append((c, luminosity, subimg))

        is_female = isFemale(c)
        if is_female is True:
            if female_lightest is None:
                female_lightest = luminosity
                female_darkest = luminosity
            if luminosity > female_lightest:
                female_lightest = luminosity
            if luminosity < female_darkest:
                female_darkest = luminosity
        else:
            if male_lightest is None:
                male_lightest = luminosity
                male_darkest = luminosity

            if luminosity > male_lightest:
                male_lightest = luminosity
            if luminosity < male_darkest:
                male_darkest = luminosity

        c += 1


images.sort(key=lambda x: x[0])

for i in range(len(images)):
    image = images[i]
    lightest = female_lightest if isFemale(image[0]) is True else male_lightest
    darkest = female_darkest if isFemale(image[0]) is True else male_darkest
    #remap cur_luminosity from 0 to 1 where zero is lightest and 1 is darkest
    remaped_luminosity = (image[1] - lightest) / (darkest - lightest)
    print(f"[{image[0]}] = {min(1.0,max(0.0,remaped_luminosity))},")