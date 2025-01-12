import os
import cv2
import numpy as np
from scipy import ndimage


class leaf_segmentation:
    filter_size = (1, 1)
    filter_sigma = 5
    otsu_threshold_min = 0
    otsu_threshold_max = 255
    SE = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (15, 15))

    def _create_otsu_mask(self, img):
        mask = cv2.threshold(img, self.otsu_threshold_min, self.otsu_threshold_max, cv2.THRESH_OTSU)[1]
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, self.SE)
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, self.SE)
        return ndimage.binary_fill_holes(mask)

    def _refine_segmentation(self, img):
        gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        brightened_img = cv2.convertScaleAbs(gray_img, alpha=1.2, beta=50)
        binary_mask = cv2.threshold(brightened_img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
        contours = cv2.findContours(binary_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[0]
        largest_contour = max(contours, key=cv2.contourArea)
        refined_mask = np.zeros_like(binary_mask)
        cv2.drawContours(refined_mask, [largest_contour], -1, 255, thickness=cv2.FILLED)
        return cv2.bitwise_and(img, img, mask=refined_mask)

    def _process_channel(self, img_copy, channel):
        channel = cv2.equalizeHist(channel)
        channel = cv2.GaussianBlur(channel, self.filter_size, self.filter_sigma)
        mask = self._create_otsu_mask(channel)
        img_copy[mask == 0] = 0
        return self._refine_segmentation(img_copy)

    def _fill_background(self, img, fill_value):
        gray_mask = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        binary_mask = cv2.threshold(gray_mask, 1, 255, cv2.THRESH_BINARY)[1]
        inverted_mask = cv2.bitwise_not(binary_mask)
        background = np.full_like(img, fill_value)
        filled_background = cv2.bitwise_and(background, background, mask=inverted_mask)
        return cv2.add(img, filled_background)

    def segment(self, img_path):
        rgb_img = cv2.imread(img_path)
        blue, green, red = cv2.split(rgb_img)
        channels = [
            cv2.subtract(green, red),
            cv2.subtract(green, blue),
            cv2.divide(green, red),
        ]

        combined_result = self._process_channel(np.copy(rgb_img), channels[0])
        for channel in channels[1:]:
            refined_result = self._process_channel(np.copy(rgb_img), channel)
            combined_result = cv2.bitwise_and(combined_result, refined_result)
        final_result = self._fill_background(combined_result, 255)

        directory = os.environ["HOME"]
        filename = os.path.basename(img_path)
        output_path = os.path.join(directory, f"segmented_{filename}")
        cv2.imwrite(output_path, final_result)
        return output_path
