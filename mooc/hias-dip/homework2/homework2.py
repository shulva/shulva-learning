#! /usr/bin/env python3
import matplotlib.pyplot as pyplot
import cv2
import numpy as np

# 1----------------------------------------------------
img1 = cv2.imread("west.png", 0)
edges = cv2.Canny(img1, 30, 70)  # canny 边缘检测
drawing = np.zeros(img1.shape[:], dtype=np.uint8)

lines = cv2.HoughLinesP(edges, 0.8, np.pi / 180, 90)

t1, t2, temp_x, temp_y = lines[0][0]

for line in lines:
    x1, y1, x2, y2 = line[0]
    cv2.line(img1, (x1, y1), (x2, y2), (255, 255, 255), 1, lineType=cv2.LINE_AA)
# 1----------------------------------------------------
cv2.imwrite('canny.png', img1)
