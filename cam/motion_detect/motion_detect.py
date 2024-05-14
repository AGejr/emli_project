#!/usr/bin/env python3
'''
2022-2024 Kjeld Jensen

sudo apt install python3-opencv
'''

# parameters

# imports
import sys
import cv2
import numpy as np
import os
import logging
from datetime import datetime, timezone

# Custom Formatter to include milliseconds and timezone offset in the desired format
class CustomFormatter(logging.Formatter):
    def formatTime(self, record, datefmt=None):
        dt = datetime.fromtimestamp(record.created, timezone.utc).astimezone()
        t = dt.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]
        tz = dt.strftime('%z')
        tz_formatted = f"{tz[:3]}:{tz[3:]}"
        return f"{t}{tz_formatted}"

# Configure logging
log_formatter = CustomFormatter('%(asctime)s - %(levelname)s - %(message)s')
handler = logging.FileHandler('../take_photo.log')
handler.setFormatter(log_formatter)
logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.addHandler(handler)

class cam_class():
    def __init__(self):
        pass
        
    def img_scale(self, img):
        scale_percent = 15  # percent of original size
        width = int(img.shape[1] * scale_percent / 100)
        height = int(img.shape[0] * scale_percent / 100)
        dim = (width, height)
        img_scaled = cv2.resize(img, dim, interpolation=cv2.INTER_AREA)
        return img_scaled

    def img_process(self, img):
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        img = self.img_scale(img)
        img = cv2.GaussianBlur(img, (21, 21), 0)
        return img
        
    def motion_detect(self, path_img1, path_img2):
        motion = False
        img1 = self.img_process(cv2.imread(path_img1))
        img2 = self.img_process(cv2.imread(path_img2))
        
        # inspired by https://raw.githubusercontent.com/cristianpb/object-detection/master/backend/motion.py
        img_diff = cv2.absdiff(img1, img2)

        # 4. Dilute the image a bit to make differences more seeable; more suitable for contour detection
        kernel = np.ones((5, 5))
        img_diff = cv2.dilate(img_diff, kernel, 1)

        # 5. Only take different areas that are different enough (>20 / 255)
        img_thresh = cv2.threshold(src=img_diff, thresh=20, maxval=255, type=cv2.THRESH_BINARY)[1]

        contours, _ = cv2.findContours(image=img_thresh, mode=cv2.RETR_EXTERNAL, method=cv2.CHAIN_APPROX_SIMPLE)

        motion = False
        for contour in contours:
            if cv2.contourArea(contour) < 100:
                # too small: skip!
                continue
            motion = True
            (x, y, w, h) = cv2.boundingRect(contour)
            cv2.rectangle(img=img2, pt1=(x, y), pt2=(x + w, y + h), color=(255, 255, 0), thickness=4)
        if motion:
            motion = True
        output_folder = "motion_detect_images"
        if not os.path.exists(output_folder):
            os.makedirs(output_folder)
        cv2.imwrite("./motion_detect_images/motion_detect.png", img2)
        return motion
    

def main():
    cam = cam_class()
    if len(sys.argv) != 3:
        logging.error("Usage: python3 motion_detect.py file1 file2")
        return

    path_img1 = sys.argv[1]
    path_img2 = sys.argv[2]
    motion = cam.motion_detect(path_img1, path_img2)    
    if motion:
        print('Motion detected')
        logging.info('Motion detected')
    else:
        print('No motion')


if __name__ == "__main__":
    main()