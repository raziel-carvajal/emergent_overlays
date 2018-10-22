""" This module draws a topology given as a csv files without header. """
""" The first column is the x while the second is y """

import sys
import random
import math
import csv
import numpy as np
import argparse



import networkx as nx
from collections import defaultdict

import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.patches as mpatches

def get_arguments():
    parser = argparse.ArgumentParser(description='Displays the topology in the form of an animation')

    parser.add_argument('cmap_file', metavar='cmap_file', type=str,
                        help='File with the color map')

    parser.add_argument('log_file', metavar='log_file', type=str,
                        help='Log file (Produced by omnetpp when a broadcastin protocol is used)')

    args = parser.parse_args()
    return args


def read_colormap(cmap_file):
    '''
    Read the color map from a file. A color map is nothing but a csv file
    where the first column is the state and the second one is the color in text
    format.
    '''
    cmap = {}
    with open(cmap_file, 'rb') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            cmap[row[0]] = row[1]
    # FIXME: what if the file doesn't exist? Discover how to deal with that case
    # in Python
    return cmap


def read_log_file(log_file):
    data = []
    with open(log_file, 'rb') as csvfile:
        logreader = csv.reader(csvfile, delimiter=',')
        for row in logreader:
            data.append({'name': row[1], 'time': float(row[2]), 'x': float(row[3]), 'y': float(row[4]), 'status': row[5]})
    return data


def plot_egdes(ax, nodes, tx=10, callback_line_style=lambda n1, n2: '-'):
    for k1 in nodes:
        x1 = nodes[k1]['x']
        y1 = nodes[k1]['y']
        for k2 in nodes:
            if k1 != k2:
                x2 = nodes[k2]['x']
                y2 = nodes[k2]['y']
                dist = (x1-x2)**2 + (y1-y2)**2
                if dist <= tx**2:
                    s = callback_line_style(nodes[k1], nodes[k2])
                    ax.plot([x1, x2], [y1, y2], c='red', linewidth=1.3, linestyle=s)
    pass


def plot_nodes(ax, nodes, color_map):
    px = [nodes[k]['x'] for k in nodes]
    py = [nodes[k]['y'] for k in nodes]
    cc = [color_map[nodes[k]['status']] for k in nodes]
    names = [k[5:] for k in nodes]
    scatter = ax.scatter(px, py, marker="o", c=cc, s=144)
    for i, txt in enumerate(names):
        ax.annotate(txt, (px[i]+1, py[i]+1))


    ax.legend([mpatches.Rectangle((0,0),1,1,fc=color_map[k]) for k in color_map],
              [k for k in color_map], loc='upper center', bbox_to_anchor=(0.5, 1.08),
              ncol=3, fancybox=True, shadow=True)

    return scatter


if __name__ == '__main__':
    args = get_arguments()
    data = read_log_file(args.log_file)
    cmap = read_colormap(args.cmap_file)

    # create dictionary
    d = {}
    for e in data:
        if not e['name'] in d:
            d[e['name']] = {'status': e['status'], 'x': e['x'], 'y': e['y']}

    data = [ e for e in data if e['status'] != 'STANDING']

    # draw initial stuff
    fig, ax = plt.subplots()

    plot_egdes(ax=ax, nodes=d)
    graph_nodes = plot_nodes(ax=ax, nodes=d, color_map=cmap)

    def animate(i):
        name = data[i]['name']
        status = data[i]['status']
        time = data[i]['time']
        print i, name, time
        d[name]['status'] = status
        colors = [cmap[d[k]['status']] for k in d]
        graph_nodes.set_facecolor(colors)
        return graph_nodes,

    ani = animation.FuncAnimation(fig, animate, np.arange(0, len(data)),
                                  interval=50, blit=False, repeat=False)

    plt.show()

    print "Plotting final graph"
    fig, ax = plt.subplots()

    def final_linestyle(n1, n2):
        return ' ' if n1['status'] != 'MARKED' else '-' if n2['status'] == 'MARKED' else '--'
    plot_egdes(ax=ax, nodes=d, callback_line_style=final_linestyle)
    plot_nodes(ax=ax, nodes=d, color_map=cmap)
    plt.show()

    print "Done"
