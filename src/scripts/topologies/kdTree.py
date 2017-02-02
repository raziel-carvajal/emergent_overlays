
import random

from PIL import Image, ImageDraw


class Node:
    def __init__(self, x, y, w, h, min_size, rnd, threshold=0.3):
        self.w, self.h = w, h
        self.x, self.y = x, y
        self.child1 = None
        self.child2 = None
        if w/2 >= min_size and h/2 >= min_size and rnd.random() > threshold:
            if w > h:
                self.child1 = Node(x, y, w/2, h, min_size, rnd)
                self.child2 = Node(x + w/2, y, w/2, h, min_size, rnd)
            else:
                self.child1 = Node(x, y, w, h/2, min_size, rnd)
                self.child2 = Node(x, y + h/2, w, h/2, min_size, rnd)

    def is_leaf(self):
        return self.child1 is None and self.child2 is None


class KDTree:

    def __init__(self, w, h, min_size, rnd=random.Random()):
        self.w = w
        self.h = h
        self.min_size = min_size
        self.root = Node(0, 0, w, h, min_size, rnd)

    def apply_to_each_leaf(self, f):
        result = []
        stack = [self.root]
        while len(stack) > 0:
            node = stack.pop()
            if node.is_leaf():
                result.append(f(node))
            else:
                stack.append(node.child1)
                stack.append(node.child2)
        return result


def generate_image(tree, map_w, map_h, filename):
    im = Image.new("RGB", (map_w, map_h), "white")

    draw = ImageDraw.Draw(im)

    def image_generation(node):
        draw.rectangle([node.x, node.y, node.x + node.w, node.y + node.h], fill=None, outline="red")

    tree.apply_to_each_leaf(image_generation)

    im.save(filename, "PNG")


def generate_tree(map_w, map_h):
    map_w, map_h = 1000, 1000

    while True:
        tree = KDTree(w=map_w, h=map_h, min_size=100)
        l = tree.apply_to_each_leaf(lambda n: 1)
        if len(l) >= 10:
            break

    return tree


def save_tree_as_image(tree, image_filename):
    generate_image(tree, tree.w, tree.h, image_filename)


if __name__ == '__main__':

    t = generate_tree(1000, 1000)
    save_tree_as_image(t, "pepe.png")
