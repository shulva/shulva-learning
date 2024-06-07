import cv2


def sort_outlet(outlet, method='left2right'):
    boxs = [cv2.boundingRect(o) for o in outlet]
    reverse = False
    i = 0
    if method == 'right2left' or method == 'bottom2top':
        reverse = True
    if method == 'top2bottom' or method == 'bottom2top':
        i = 1

    (outlet, boxs) = zip(*sorted(zip(outlet, boxs), key=lambda x: x[1][i], reverse=reverse))

    return outlet, boxs


def template():
    img = cv2.imread('template.png')
    template_to_find = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    template_to_find = cv2.threshold(template_to_find, 10, 255, cv2.THRESH_BINARY_INV)[1]
    cv2.imwrite('template_to_find.png', template_to_find)

    outlet, attribute = cv2.findContours(template_to_find.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    #cv2.drawContours(img, outlet, -1, (0, 0, 255), 3)
    #cv2.imshow("img", img)
    #cv2.waitKey(0)

    sorted_outlet = sort_outlet(outlet)[0]

    digit2outlet = {}

    for i, o in enumerate(sorted_outlet):
        (x, y, w, h) = cv2.boundingRect(o)
        box = template[y:y + h, x:x + w]
        box = cv2.resize(box, (60, 90))
        digit2outlet[i] = box


if __name__ == "__main__":
    template()
