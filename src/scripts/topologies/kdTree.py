
import random

from PIL import Image, ImageDraw


class Node:
    def __init__(self, x, y, w, h, min_size, rnd, threshold=0.3):
        self.w, self.h = w, h
        self.x, self.y = x, y
        self.child1 = None
        self.child2 = None
        if (w/2 >= min_size or h/2 >= min_size) and rnd.random() > threshold:
            if w > h:
                self.child1 = Node(x, y, w/2, h, min_size, rnd)
                self.child2 = Node(x + w/2, y, w/2, h, min_size, rnd)
            else:
                self.child1 = Node(x, y, w, h/2, min_size, rnd)
                self.child2 = Node(x, y + h/2, w, h/2, min_size, rnd)

    def is_leaf(self):
        return self.child1 is None and self.child2 is None

    def contains(self, x, y):
        return x >= self.x and x <= (self.x + self.w) and y >= (self.y) and y <= (self.y + self.h)

    def find_leaf(self, x, y):
        if not self.is_leaf():
            if (self.child1 is not None) and self.child1.contains(x, y):
                return self.child1.find_leaf(x, y)
            if (self.child2 is not None) and self.child2.contains(x, y):
                return self.child2.find_leaf(x, y)
        else:
            return self if self.contains(x, y) else None


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

    def find_leaf(self, x, y):
        return self.root.find_leaf(x, y)


def generate_image(tree, map_w, map_h, filename, positions, colorful_densities):
    im = Image.new("RGB", (int(map_w), int(map_h)), "white")

    draw = ImageDraw.Draw(im)

    def image_generation(node):
        mapping = {5:'gray', 10:'green', 15:'blue', 20:'brown', 25:'yellow', 30:'pink', 35:'red'}
        color = None
        if colorful_densities and hasattr(node, 'density'):
            if node.density in mapping:
                color = mapping[node.density]
        draw.rectangle([int(node.x), int(node.y), int(node.x + node.w), int(node.y + node.h)], fill=color, outline="red")


    if tree is not None:
    	tree.apply_to_each_leaf(image_generation)

    for p in positions:
        draw.ellipse([p[0], p[1], p[0] + 2, p[1] + 2], fill="green")

    im.save(filename, "PNG")


def generate_tree(map_w=1000, map_h=1000, min_size=100, min_number_leaf=10):

    while True:
        tree = KDTree(w=map_w, h=map_h, min_size=min_size)
        l = tree.apply_to_each_leaf(lambda n: 1)
        # print len(l)
        if len(l) == min_number_leaf:
            break

    return tree


def save_tree_as_image(tree, image_filename, positions=[], colorful_densities=False):
    generate_image(tree, tree.w, tree.h, image_filename, positions, colorful_densities)


if __name__ == '__main__':

    t = generate_tree(1000, 1000)
    save_tree_as_image(t, "pepe.png")
